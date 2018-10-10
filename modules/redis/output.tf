output "configuration_endpoint_address" {
	value = "${aws_elasticache_replication_group.this.configuration_endpoint_address}"
}

output "member_clusters" {
	value = "${aws_elasticache_replication_group.this.member_clusters}"
}

