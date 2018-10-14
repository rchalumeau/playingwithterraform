variable "prefix" {
	description = "Prefix to easily identify the resources"
}

variable "region" {
	description = "AWS region"
}

variable "number_zones" {
	description = "Number of availability zones"
}

variable "cidr" { 
	description = "CIDR of the virtual network"
}

###

variable "domain" {
 	description = "route53 zone to be used"
}

variable "subdomain" {
	description = "Subdomain to be crested poijting at the ECS containers" 
}

