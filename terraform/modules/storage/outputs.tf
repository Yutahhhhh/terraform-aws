# フロントエンド用バケット
output "frontend_bucket_id" {
  description = "フロントエンド用S3バケットID"
  value       = aws_s3_bucket.frontend.id
}

output "frontend_bucket_arn" {
  description = "フロントエンド用S3バケットARN"
  value       = aws_s3_bucket.frontend.arn
}

output "frontend_bucket_domain_name" {
  description = "フロントエンド用S3バケットドメイン名"
  value       = aws_s3_bucket.frontend.bucket_domain_name
}

output "frontend_bucket_regional_domain_name" {
  description = "フロントエンド用S3バケットリージョナルドメイン名"
  value       = aws_s3_bucket.frontend.bucket_regional_domain_name
}

# ALBアクセスログ用バケット
output "alb_logs_bucket_id" {
  description = "ALBアクセスログ用S3バケットID"
  value       = var.enable_alb_access_logs ? aws_s3_bucket.alb_logs[0].id : null
}

output "alb_logs_bucket_name" {
  description = "ALBアクセスログ用S3バケット名"
  value       = var.enable_alb_access_logs ? aws_s3_bucket.alb_logs[0].bucket : null
}

output "alb_logs_bucket_arn" {
  description = "ALBアクセスログ用S3バケットARN"
  value       = var.enable_alb_access_logs ? aws_s3_bucket.alb_logs[0].arn : null
}

output "alb_logs_bucket_domain_name" {
  description = "ALBアクセスログ用S3バケットドメイン名"
  value       = var.enable_alb_access_logs ? aws_s3_bucket.alb_logs[0].bucket_domain_name : null
}

# CloudFrontアクセスログ用バケット
output "cloudfront_logs_bucket_id" {
  description = "CloudFrontアクセスログ用S3バケットID"
  value       = var.enable_cloudfront_logging ? aws_s3_bucket.cloudfront_logs[0].id : null
}

output "cloudfront_logs_bucket_arn" {
  description = "CloudFrontアクセスログ用S3バケットARN"
  value       = var.enable_cloudfront_logging ? aws_s3_bucket.cloudfront_logs[0].arn : null
}

output "cloudfront_logs_bucket_domain_name" {
  description = "CloudFrontアクセスログ用S3バケットドメイン名"
  value       = var.enable_cloudfront_logging ? aws_s3_bucket.cloudfront_logs[0].bucket_domain_name : null
}

# CI/CDアーティファクト用バケット
output "artifacts_bucket_id" {
  description = "CI/CDアーティファクト用S3バケットID"
  value       = var.enable_cicd ? aws_s3_bucket.artifacts[0].id : null
}

output "artifacts_bucket_name" {
  description = "CI/CDアーティファクト用S3バケット名"
  value       = var.enable_cicd ? aws_s3_bucket.artifacts[0].bucket : null
}

output "artifacts_bucket_arn" {
  description = "CI/CDアーティファクト用S3バケットARN"
  value       = var.enable_cicd ? aws_s3_bucket.artifacts[0].arn : null
}

output "artifacts_bucket_domain_name" {
  description = "CI/CDアーティファクト用S3バケットドメイン名"
  value       = var.enable_cicd ? aws_s3_bucket.artifacts[0].bucket_domain_name : null
}

# バックアップ用バケット
output "backup_bucket_id" {
  description = "バックアップ用S3バケットID"
  value       = var.enable_backup ? aws_s3_bucket.backup[0].id : null
}

output "backup_bucket_arn" {
  description = "バックアップ用S3バケットARN"
  value       = var.enable_backup ? aws_s3_bucket.backup[0].arn : null
}

output "backup_bucket_domain_name" {
  description = "バックアップ用S3バケットドメイン名"
  value       = var.enable_backup ? aws_s3_bucket.backup[0].bucket_domain_name : null
}

# 設定情報
output "versioning_enabled" {
  description = "バージョニングが有効かどうか"
  value       = var.enable_versioning
}

output "alb_access_logs_enabled" {
  description = "ALBアクセスログが有効かどうか"
  value       = var.enable_alb_access_logs
}

output "cloudfront_logging_enabled" {
  description = "CloudFrontログが有効かどうか"
  value       = var.enable_cloudfront_logging
}

output "cicd_enabled" {
  description = "CI/CDが有効かどうか"
  value       = var.enable_cicd
}

output "backup_enabled" {
  description = "バックアップが有効かどうか"
  value       = var.enable_backup
}
