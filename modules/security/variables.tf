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

variable "s3_user_uploads_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket for user uploads"
}