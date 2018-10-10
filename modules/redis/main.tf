# set the elasticache subnet group with provided subnets
resource "aws_elasticache_subnet_group" "this" {

    name 		= "${var.name}-subnet-group"
    description 	= "private subnets"

    subnet_ids 		= [ "${var.subnet_ids}" ]
}

# FIXME : token could be longer for prod... 
resource "random_string" "auth_token" {

  length            	= 16
  special		= false
}

# redis cluster 
resource "aws_elasticache_replication_group" "this" {

  engine 			= "redis"

  node_type                     = "${var.node_type}"
  port                          = 6379

  #number_cache_clusters        = 2
  cluster_mode {
    # One cluster per subnet
    num_node_groups             = "${length(var.subnet_ids)}"
    replicas_per_node_group     = "${var.replica_count}"
  }

  replication_group_description = "${var.name} Redis replication group"
  replication_group_id          = "${var.name}"

  # Confidentiality
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = true
  auth_token                    = "${random_string.auth_token.result}"
  security_group_ids            = [ "${aws_security_group.this.id}" ]

  # automate maintenance
  auto_minor_version_upgrade    = true
  maintenance_window		= sun:02:00-sun:04:00

  # availability
  automatic_failover_enabled    = true
  
  # integrity
  snapshot_retention_limit      = 2
  snapshot_window               = "02:00-03:00"

  subnet_group_name             = "${aws_elasticache_subnet_group.this.name}"
  tags                          = { Name = "${var.name}-cluster" }

  apply_immediately		= true

}

# Set firewall rules
resource "aws_security_group" "this" {

    name 			= "${var.name}-sg"
    description 		= "Allow Redis from processing layer"

    vpc_id 			= "${var.vpc_id}"

    # FIXME : accept only the connections from the provided cidrs on the needed port (reducing the attack surface)
    ingress {
        from_port 		= 0
        to_port 		= 0
        protocol 		= "-1"
        cidr_blocks 		= [ "0.0.0.0/0" ]
    }

    # FIXME : Open outbound internet (to be checked if necessary)
    egress {
        from_port 		= 0
        to_port 		= 0
        protocol 		= "-1"
        cidr_blocks 		= [ "0.0.0.0/0" ]
    }
}
