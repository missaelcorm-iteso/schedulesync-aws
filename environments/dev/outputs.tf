output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs_cluster.cluster_name
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "frontend_service_name" {
  description = "Frontend service name"
  value       = module.frontend_service.service_name
}

output "backend_service_name" {
  description = "Backend service name"
  value       = module.backend_service.service_name
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log group names"
  value = {
    frontend = module.frontend_service.cloudwatch_log_group_name
    backend  = module.backend_service.cloudwatch_log_group_name
  }
}