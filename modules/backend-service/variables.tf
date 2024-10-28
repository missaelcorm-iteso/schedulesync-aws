variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "ecs_cluster_id" {
  type        = string
  description = "ECS cluster ID"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for the service"
}

variable "execution_role_arn" {
  type        = string
  description = "ECS task execution role ARN"
}

variable "task_role_arn" {
  type        = string
  description = "ECS task role ARN"
}

variable "service_discovery_namespace_id" {
  type        = string
  description = "Service discovery namespace ID"
}

variable "ecr_repository_url" {
  type        = string
  description = "ECR repository URL for the container image"
}

variable "container_image_tag" {
  type        = string
  description = "Container image tag"
  default     = "latest"
}

variable "container_port" {
  type        = number
  description = "Container port"
  default     = 3000
}

variable "container_cpu" {
  type        = number
  description = "Container CPU units"
  default     = 256
}

variable "container_memory" {
  type        = number
  description = "Container memory in MiB"
  default     = 512
}

variable "desired_count" {
  type        = number
  description = "Desired number of tasks"
  default     = 3
}

variable "health_check_path" {
  type        = string
  description = "Health check path"
  default     = "/health"
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "Environment variables for the container"
  default     = []
}

variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  description = "Secrets for the container"
  default     = []
}