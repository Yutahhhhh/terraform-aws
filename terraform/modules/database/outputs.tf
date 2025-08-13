output "db_instance_id" {
  description = "RDSインスタンスID"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "RDSインスタンスARN"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "RDSインスタンスエンドポイント"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "RDSインスタンスアドレス"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "RDSインスタンスポート"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "データベース名"
  value       = aws_db_instance.main.db_name
}

output "db_subnet_group_name" {
  description = "DBサブネットグループ名"
  value       = aws_db_subnet_group.main.name
}

output "db_parameter_group_name" {
  description = "DBパラメータグループ名"
  value       = aws_db_parameter_group.main.name
}

output "db_secret_arn" {
  description = "データベース認証情報のSecrets Manager ARN"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_secret_name" {
  description = "データベース認証情報のSecrets Manager名"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "db_proxy_endpoint" {
  description = "RDS Proxyエンドポイント"
  value       = var.enable_rds_proxy ? aws_db_proxy.main[0].endpoint : null
}

output "db_proxy_arn" {
  description = "RDS Proxy ARN"
  value       = var.enable_rds_proxy ? aws_db_proxy.main[0].arn : null
}

output "performance_insights_enabled" {
  description = "Performance Insightsが有効かどうか"
  value       = var.enable_performance_insights
}

output "kms_key_id" {
  description = "Performance Insights用KMSキーID"
  value       = var.enable_performance_insights ? aws_kms_key.rds[0].id : null
}

output "kms_key_arn" {
  description = "Performance Insights用KMSキーARN"
  value       = var.enable_performance_insights ? aws_kms_key.rds[0].arn : null
}

output "monitoring_role_arn" {
  description = "Enhanced Monitoring用IAMロールARN"
  value       = var.enable_performance_insights ? aws_iam_role.rds_monitoring[0].arn : null
}
