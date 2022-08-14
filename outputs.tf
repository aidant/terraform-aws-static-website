output "aws_s3_bucket_arn" {
  value       = aws_s3_bucket.static_website.arn
  description = "The AWS S3 Bucket ARN for the static website."
}
