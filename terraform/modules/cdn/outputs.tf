output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_distribution_arn" {
  description = "CloudFront Distribution ARN"
  value       = aws_cloudfront_distribution.frontend.arn
}

output "cloudfront_domain_name" {
  description = "CloudFront Distribution Domain Name"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront Distribution Hosted Zone ID"
  value       = aws_cloudfront_distribution.frontend.hosted_zone_id
}

output "origin_access_control_id" {
  description = "Origin Access Control ID"
  value       = aws_cloudfront_origin_access_control.frontend.id
}

output "cloudfront_logs_bucket_name" {
  description = "CloudFrontログ用S3バケット名"
  value       = var.enable_cloudfront_logging ? aws_s3_bucket.cloudfront_logs[0].bucket : null
}

output "cloudfront_logs_bucket_arn" {
  description = "CloudFrontログ用S3バケットARN"
  value       = var.enable_cloudfront_logging ? aws_s3_bucket.cloudfront_logs[0].arn : null
}
