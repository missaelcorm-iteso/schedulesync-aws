variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "domain_name" {
  type        = string
  description = "Main domain name"
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "Additional domain names for the certificate"
  default     = []
}