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

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for the ALB"
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the SSL certificate"
}

variable "frontend_health_check_path" {
  type        = string
  description = "Health check path for frontend service"
  default     = "/"
}

variable "backend_health_check_path" {
  type        = string
  description = "Health check path for backend service"
  default     = "/health"
}

variable "app_domain" {
  type        = string
  description = "App domain"
}