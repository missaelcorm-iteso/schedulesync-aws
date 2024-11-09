output "cluster_endpoint" {
  description = "The cluster endpoint"
  value       = aws_docdb_cluster.default.endpoint
}

output "cluster_reader_endpoint" {
  description = "The cluster reader endpoint"
  value       = aws_docdb_cluster.default.reader_endpoint
}

output "cluster_port" {
  description = "The cluster port"
  value       = aws_docdb_cluster.default.port
}

output "cluster_instances" {
  description = "List of cluster instance IDs"
  value       = aws_docdb_cluster_instance.cluster_instances[*].id
}
