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

variable "enable_container_insights" {
  type        = bool
  description = "Enable CloudWatch Container Insights"
  default     = true
}

variable "capacity_providers" {
  type        = list(string)
  description = "List of capacity providers"
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider_strategy" {
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = number
  }))
  description = "Default capacity provider strategy"
  default = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    },
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 4
      base              = 0
    }
  ]
}