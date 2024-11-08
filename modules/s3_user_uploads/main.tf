locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket" "user_uploads" {
  bucket = var.bucket_name
  force_destroy = true

  # tfsec:ignore:aws-s3-enable-bucket-encryption
  # tfsec:ignore:aws-s3-encryption-customer-key

  tags = merge(
    var.tags,
    local.common_tags
  )
}

# Enable versioning for recovery
resource "aws_s3_bucket_versioning" "user_uploads" {
  bucket = aws_s3_bucket.user_uploads.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure public access
resource "aws_s3_bucket_public_access_block" "user_uploads" {
  bucket = aws_s3_bucket.user_uploads.id

  block_public_acls       = false # tfsec:ignore:aws-s3-block-public-acls
  block_public_policy     = false # tfsec:ignore:aws-s3-block-public-policy
  ignore_public_acls      = false # tfsec:ignore:aws-s3-ignore-public-acls
  restrict_public_buckets = false # tfsec:ignore:aws-s3-no-public-buckets
}

# Bucket policy for public read
resource "aws_s3_bucket_policy" "user_uploads" {
  bucket = aws_s3_bucket.user_uploads.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.user_uploads.arn}/*"]
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.user_uploads]
}

# Optional: Configure CORS if needed for direct frontend access
resource "aws_s3_bucket_cors_configuration" "user_uploads" {
  bucket = aws_s3_bucket.user_uploads.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = var.allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
