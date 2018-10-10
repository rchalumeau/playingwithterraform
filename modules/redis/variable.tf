variable "name" {}

variable "vpc_id" {
        description = "id of the root vpc"
}

variable "subnet_ids"  {
	description = "List of private subnets hosting redis"
	type 	    = "list"
}

variable "node_type" {
	description = "size of the redis nodes"
}

variable "replica_count" {
	description = "number of read replica node per cluster"
}


