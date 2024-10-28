variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "Additional domain names for the certificate"
  default     = []
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token"
}

variable "root_domain" {
  type        = string
  description = "Root domain (e.g., example.com)"
}