output "vpc_endpoints_security_group_id" {
  description = "VPCエンドポイント用セキュリティグループID"
  value       = aws_security_group.vpc_endpoints.id
}

output "s3_endpoint_id" {
  description = "S3 VPCエンドポイントID"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.s3[0].id : null
}

output "ecr_api_endpoint_id" {
  description = "ECR API VPCエンドポイントID"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.ecr_api[0].id : null
}

output "ecr_dkr_endpoint_id" {
  description = "ECR DKR VPCエンドポイントID"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.ecr_dkr[0].id : null
}

output "logs_endpoint_id" {
  description = "CloudWatch Logs VPCエンドポイントID"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.logs[0].id : null
}

output "secrets_manager_endpoint_id" {
  description = "Secrets Manager VPCエンドポイントID"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.secrets_manager[0].id : null
}

output "xray_endpoint_id" {
  description = "X-Ray VPCエンドポイントID"
  value       = var.enable_vpc_endpoints && var.enable_xray_tracing ? aws_vpc_endpoint.xray[0].id : null
}

output "vpc_flow_logs_log_group_name" {
  description = "VPCフローログのCloudWatch Log Group名"
  value       = var.enable_vpc_flow_logs ? aws_cloudwatch_log_group.vpc_flow_logs[0].name : null
}

output "vpc_flow_logs_role_arn" {
  description = "VPCフローログ用IAMロールARN"
  value       = var.enable_vpc_flow_logs ? aws_iam_role.vpc_flow_logs[0].arn : null
}
