variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "alb_dns_name" {
  type        = string
  description = "ALB DNS name"
}

variable "enable_proxy" {
  type        = bool
  description = "Enable Cloudflare proxy (orange cloud)"
  default     = true
}