output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "frontend_security_group_id" {
  description = "ID of the frontend service security group"
  value       = aws_security_group.frontend.id
}

output "backend_security_group_id" {
  description = "ID of the backend service security group"
  value       = aws_security_group.backend.id
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "frontend_task_role_arn" {
  description = "ARN of the frontend task role"
  value       = aws_iam_role.frontend_task.arn
}

output "backend_task_role_arn" {
  description = "ARN of the backend task role"
  value       = aws_iam_role.backend_task.arn
}