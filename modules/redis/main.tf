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
    num_node_groups             = "${var.group_count}"
    replicas_per_node_group     = "${var.replica_count}"
  }

  replication_group_description = "${var.name} Redis replication group"
  replication_group_id          = "${var.name}"

  # Confidentiality
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = false
  #auth_token                    = "${random_string.auth_token.result}"
  security_group_ids            = [ "${var.sg}" ]

  # automate maintenance
  auto_minor_version_upgrade    = true
  maintenance_window		= "sun:02:00-sun:04:00"

  # availability
  automatic_failover_enabled    = true
  
  # integrity
  snapshot_retention_limit      = 2
  snapshot_window               = "00:00-01:00"

  subnet_group_name             = "${var.subnet_name}"
  tags                          = { Name = "${var.name}-cluster" }

  apply_immediately		= true

}
