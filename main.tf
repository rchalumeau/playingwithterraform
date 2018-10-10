provider "aws" {
  region     = "${var.region}"
  profile    = "terraform"

  version = "~> 1.39"

}

provider "random"    { version = "~> 2.0" }

####################

# Determine the availability zones according to the expected number
data "aws_availability_zones" "available" {}
locals {
	az	= "${slice(data.aws_availability_zones.available.names, 0, var.number_zones)}"
}

### Create network infra (Pub and private network on x az)
module "network" {
  source        = "./modules/pub_priv_network"
  name		= "${var.prefix}-network"

  cidr		= "${var.cidr}"
  azs           = "${local.az}"

}

# Create redis infra
module "redis" {

  source        = "./modules/redis"
  name          = "${var.prefix}-redis"

  # On which subnets should it be installed
  vpc_id       	= "${module.network.vpc_id}"
  subnet_ids    = "${module.network.private_ids}"
  
  node_type	= "cache.t2.micro"
  replica_count	= 1 # One read replica per cluster

}

# Debug
output "az" { value = "${local.az}" }
output "cidrs" { value = "${module.network.private_ids}" }
output "redis_members" { value = "${module.redis.member_clusters}" }
output "redis_endpoint" { value = "${module.redis.configuration_endpoint_address}" }


