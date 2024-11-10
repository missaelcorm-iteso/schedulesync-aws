locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# tfsec:ignore:aws-s3-enable-bucket-encryption tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket" "user_uploads" {
  bucket        = var.bucket_name
  force_destroy = true

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

resource "aws_s3_bucket_ownership_controls" "user_uploads" {
  bucket = aws_s3_bucket.user_uploads.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Configure public access
resource "aws_s3_bucket_public_access_block" "user_uploads" {
  bucket = aws_s3_bucket.user_uploads.id

  block_public_acls       = true
  block_public_policy     = false # tfsec:ignore:aws-s3-block-public-policy
  ignore_public_acls      = true
  restrict_public_buckets = false # tfsec:ignore:aws-s3-no-public-buckets
}

# Bucket policy for public read
resource "aws_s3_bucket_policy" "user_uploads" {
  bucket = aws_s3_bucket.user_uploads.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.user_uploads.arn}/*"]
      },
      {
        Sid    = "AllowECSUpload"
        Effect = "Allow"
        Principal = {
          AWS = var.backend_task_role_arn
        }
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.user_uploads.arn,
          "${aws_s3_bucket.user_uploads.arn}/*"
        ]
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
