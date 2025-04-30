output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.cdn_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.cdn_bucket.arn
}

output "bucket_domain_name" {
  description = "The domain name of the bucket"
  value       = aws_s3_bucket.cdn_bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the bucket"
  value       = aws_s3_bucket.cdn_bucket.bucket_regional_domain_name
}
