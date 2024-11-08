variable "project" {
  type        = string
  description = "Project name"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, staging)"
  type        = string
}

variable "allowed_origins" {
  description = "List of allowed CORS origins"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "backend_task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}