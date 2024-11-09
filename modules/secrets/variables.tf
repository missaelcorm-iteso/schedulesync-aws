variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "docdb_host" {
  description = "DocumentDB cluster endpoint"
  type        = string
}

variable "docdb_port" {
  description = "DocumentDB cluster port"
  type        = number
}

variable "docdb_name" {
  description = "DocumentDB database name"
  type        = string
  default = "schedule_sync"
}