output "bucket_name" {
  value = aws_s3_bucket.user_uploads.id
}

output "bucket_domain_name" {
  value = aws_s3_bucket.user_uploads.bucket_domain_name
}

output "bucket_arn" {
  value = aws_s3_bucket.user_uploads.arn
}