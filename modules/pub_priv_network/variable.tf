variable "name" {}

variable "cidr" {
        description = "CIDR dedicated to the public subnets"
}

variable "azs"  {
	description = "List of availability zones"
	type = "list"
}
