variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DocumentDB cluster"
  type        = list(string)
}

variable "instance_class" {
  description = "Instance class for DocumentDB cluster instances"
  type        = string
  default     = "db.t3.medium"
}

variable "instance_count" {
  description = "Number of instances in the DocumentDB cluster"
  type        = number
  default     = 1
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply changes immediately"
  type        = bool
  default     = false
}

variable "tls_enabled" {
  description = "Enable TLS encryption"
  type        = bool
  default     = true
}

variable "master_username" {
  description = "Master username for DocumentDB cluster"
  type        = string
  sensitive   = true
}

variable "master_password" {
  description = "Master password for DocumentDB cluster"
  type        = string
  sensitive   = true
}

variable "documentdb_sg_id" {
  description = "Security group ID for DocumentDB cluster"
  type        = string
}