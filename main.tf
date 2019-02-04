# VPC infra
module "vpc" {

  source  			= "terraform-aws-modules/vpc/aws"
  version 			= "1.46.0"

  name 				= "${var.prefix}-vpc"
  cidr 				= "${var.cidr}"

  azs             		= [ "${local.az}" ]
  elasticache_subnets 		    = [ "${local.private}" ]
  public_subnets  		        = [ "${local.public}" ]

  tags				= { Name = "${var.prefix}-vpc" }

}


# Set security groups
# Open public to HTTP
module "http_sg" {

  source                	= "terraform-aws-modules/security-group/aws//modules/http-80"

  name                  	= "${var.prefix}-http"
  description           	= "Security group for web facing"
  vpc_id                	= "${module.vpc.vpc_id}"

  ingress_cidr_blocks   	= [ "0.0.0.0/0" ]
}

module "https_sg" {

  source                        = "terraform-aws-modules/security-group/aws//modules/https-443"

  name                          = "${var.prefix}-https"
  description                   = "Security group for web facing"
  vpc_id                        = "${module.vpc.vpc_id}"

  ingress_cidr_blocks           = [ "0.0.0.0/0" ]
}


# Open to redis
module "redis_sg" {

  source                	= "terraform-aws-modules/security-group/aws//modules/redis"

  name                  	= "${var.prefix}-redis"
  description           	= "Security group for redis"
  vpc_id                	= "${module.vpc.vpc_id}"

  ingress_cidr_blocks   	= [ "${local.public}" ]

}


# Provision Redis cluster
# Create redis infra
module "redis" {

  source        		      = "./modules/redis"
  name          		      = "${var.prefix}-redis"

  # On which subnets should it be installed
  vpc_id       			= "${module.vpc.vpc_id}"
  subnet_name   		= "${module.vpc.elasticache_subnet_group_name}"
  
  node_type			= "cache.t2.micro"
  replica_count			= 1 # One read replica per cluster
  group_count			= "${var.number_zones}"

  sg				= "${module.redis_sg.this_security_group_id}"
}


# Logs
resource "aws_cloudwatch_log_group" "app" {
  name                          = "${var.prefix}"
  retention_in_days             = 7
}


# Generate app definition
data "template_file" "app" {
  template 			= "${file("ecs_definition/sreracha.json")}"

  vars {
     redis_url 			= "redis://${module.redis.configuration_endpoint_address}:6379"
     name			= "${aws_cloudwatch_log_group.app.name}"
     region			= "${var.region}"
  }
}

# Provision ALB
module "alb" {

  source                        = "terraform-aws-modules/alb/aws"
  load_balancer_name            = "${var.prefix}-alb"
  security_groups               = [ "${module.http_sg.this_security_group_id}", "${module.https_sg.this_security_group_id}" ]

  logging_enabled		= false
  #log_bucket_name               = "${local.bucket}"
  #log_location_prefix           = "access"

  subnets                       = [ "${module.vpc.public_subnets}" ]
  tags                          = { Name = "${var.prefix}-alb" }

  vpc_id                        = "${module.vpc.vpc_id}"

  http_tcp_listeners            = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count      = "1"

  https_listeners               = "${list(map("certificate_arn", "${aws_acm_certificate_validation.cert.certificate_arn}", "port", 443))}"
  https_listeners_count         = "1"

  target_groups                 = "${local.target_groups}"
  target_groups_count           = "1"
}



# Provision ECS cluster
module "ecs" {
  
  source 			= "./modules/ecs"
  name 				= "${var.prefix}-ecs"
  
  vpc_id			= "${module.vpc.vpc_id}"
  subnet_ids			= [ "${module.vpc.public_subnets}" ]

  fargate_cpu			= 256
  fargate_memory 		= 1024

  definition			= "${data.template_file.app.rendered}"
  app_port			= 80
  app_count			= 2
  app_family			= "app"
  sg				= [ "${module.http_sg.this_security_group_id}", "${module.https_sg.this_security_group_id}" ]
  tg				= "${element(module.alb.target_group_arns, 0)}"
}


### DEBUG ###
#output "az" { value = "${local.az}" }
#output "publiccidrs" { value = "${local.public}" }
#output "private cidrs" { value = "${local.private}" }
#output "elastocache subnets" { value = "${module.vpc.elasticache_subnet_group_name}" }
#output "vpc_id" { value = "${module.vpc.vpc_id}" }
output "def" { value = "${data.template_file.app.rendered}" }
#output "dns" { value = "${module.alb.dns_name}" }
output "test_url" { value = "https://${aws_route53_record.www.fqdn}/?q=1" }
