output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.backend.id
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.backend.name
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.backend.arn
}

output "service_discovery_service_arn" {
  description = "ARN of the service discovery service"
  value       = aws_service_discovery_service.backend.arn
}

output "service_discovery_service_name" {
  description = "Name of the service discovery service"
  value       = aws_service_discovery_service.backend.name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.backend.name
}

output "autoscaling_target_id" {
  description = "ID of the Auto Scaling target"
  value       = aws_appautoscaling_target.backend.id
}

output "service_url" {
  description = "DNS name for the backend service"
  value       = "backend.${data.aws_ecs_cluster.main.cluster_name}.local"
}

output "desired_count" {
  description = "Desired count of tasks"
  value       = aws_ecs_service.backend.desired_count
}

output "running_count" {
  description = "Number of running tasks"
  value       = aws_ecs_service.backend.running_count
}

output "service_registry_arn" {
  description = "ARN of the service registry"
  value       = aws_service_discovery_service.backend.arn
}

output "container_name" {
  description = "Name of the container"
  value       = "backend"
}

output "container_port" {
  description = "Port the container listens on"
  value       = var.container_port
}