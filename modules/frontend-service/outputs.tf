output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.frontend.id
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.frontend.name
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.frontend.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.frontend.name
}

output "autoscaling_target_id" {
  description = "ID of the Auto Scaling target"
  value       = aws_appautoscaling_target.frontend.id
}

output "desired_count" {
  description = "Desired count of tasks"
  value       = aws_ecs_service.frontend.desired_count
}

output "container_name" {
  description = "Name of the container"
  value       = "frontend"
}

output "container_port" {
  description = "Port the container listens on"
  value       = var.container_port
}

output "cpu_alarm_arn" {
  description = "ARN of the CPU high utilization alarm"
  value       = aws_cloudwatch_metric_alarm.frontend_cpu_high.arn
}

output "memory_alarm_arn" {
  description = "ARN of the memory high utilization alarm"
  value       = aws_cloudwatch_metric_alarm.frontend_memory_high.arn
}