output "bucket_name" {
  value = aws_s3_bucket.user_photos.id
}

output "bucket_domain_name" {
  value = aws_s3_bucket.user_photos.bucket_domain_name
}

output "bucket_arn" {
  value = aws_s3_bucket.user_photos.arn
}