variable "name" {}

variable "vpc_id" {
        description = "id of the root vpc"
}

variable "subnet_ids" {
	description = "IDs of the subnet"
	type =  "list"
}

variable "fargate_cpu" {
	description = "CPU for Fargate"
}

variable "fargate_memory" {
	description = "Memory for fargate"
}

variable "definition" {
	description = "Task definition file"
}

variable "app_count" {
	description = "App replicas count"
}

variable "app_port" {
        description = "Port of the app"
}


variable "sg" {
        description = "ID of the security group to use"
}

variable "tg" {
	description = "ARN of target group"
}

variable "app_family" {
	description = "Container name in the task definition"
}
