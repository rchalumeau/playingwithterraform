provider "aws" {
  region     = "${var.region}"
  profile    = "terraform"

  version = "~> 1.39"

}

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

# Debug
output "az" { value = "${local.az}" }
output "cidrs" { value = "${module.network.private_ids}" }

