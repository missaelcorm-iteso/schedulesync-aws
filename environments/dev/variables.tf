variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "ScheduleSync"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "root_domain" {
  type        = string
  description = "Root domain name (e.g., example.com)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
  default     = ["us-west-2a", "us-west-2b"]
}

variable "frontend_image" {
  type = object({
    repository_url = string
    tag            = string
  })
  description = "Frontend container image details"
}

variable "backend_image" {
  type = object({
    repository_url = string
    tag            = string
  })
  description = "Backend container image details"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token"
  sensitive   = true
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}