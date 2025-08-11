# VPC関連の出力（第1回で作成した）
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "パブリックサブネットIDのリスト"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "プライベートサブネットIDのリスト"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "availability_zones" {
  description = "使用中のアベイラビリティゾーン"
  value       = var.availability_zones
}

# Security Groups関連の出力（第2回で追加）
output "security_group_alb_id" {
  description = "ALB用Security GroupのID"
  value       = aws_security_group.alb.id
}

output "security_group_ecs_id" {
  description = "ECS用Security GroupのID"
  value       = aws_security_group.ecs.id
}

output "security_group_rds_id" {
  description = "RDS用Security GroupのID"
  value       = aws_security_group.rds.id
}

# NAT Gateway関連の出力（第2回で追加した）
output "nat_gateway_ids" {
  description = "NAT GatewayのIDリスト"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "NAT GatewayのElastic IPアドレスリスト"
  value       = aws_eip.nat[*].public_ip
}

# ALB関連の出力（第3回で追加）
output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "ALB DNS名"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB Zone ID"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.ecs.arn
}

output "alb_security_group_id" {
  description = "ALB Security Group ID（参照用）"
  value       = aws_security_group.alb.id
}

# ECS関連の出力（第4回で追加）
output "ecs_cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_execution_role_arn" {
  description = "ECS Execution Role ARN"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ECS Task Role ARN"
  value       = aws_iam_role.ecs_task_role.arn
}

# ECR
output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "ECR Repository ARN"
  value       = aws_ecr_repository.app.arn
}

# CloudWatch Logs
output "cloudwatch_log_group_name" {
  description = "CloudWatch Log Group Name"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch Log Group ARN"
  value       = aws_cloudwatch_log_group.ecs.arn
}

# RDS関連の出力（第5回で追加）
output "rds_endpoint" {
  description = "RDS エンドポイント"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "RDS アドレス（ホスト名）"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "RDS ポート番号"
  value       = aws_db_instance.main.port
}

output "rds_database_name" {
  description = "RDS データベース名"
  value       = aws_db_instance.main.db_name
}

output "db_subnet_group_id" {
  description = "DB Subnet Group ID"
  value       = aws_db_subnet_group.main.id
}

output "db_secret_arn" {
  description = "Secrets Manager Secret ARN"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_secret_name" {
  description = "Secrets Manager Secret Name"
  value       = aws_secretsmanager_secret.db_credentials.name
}

# ECS Service関連（第7回で追加）
output "ecs_service_name" {
  description = "ECS Service名"
  value       = aws_ecs_service.app.name
}

output "ecs_task_definition_arn" {
  description = "Task Definition ARN"
  value       = aws_ecs_task_definition.app.arn
}

output "ecs_task_definition_family" {
  description = "Task Definition Family"
  value       = aws_ecs_task_definition.app.family
}

# VPC Endpoints関連の出力（第8回で追加）
output "vpc_endpoint_s3_id" {
  description = "S3 VPC Endpoint ID"
  value       = try(aws_vpc_endpoint.s3[0].id, "")
}

output "vpc_endpoint_ecr_api_id" {
  description = "ECR API VPC Endpoint ID"
  value       = try(aws_vpc_endpoint.ecr_api[0].id, "")
}

output "vpc_endpoint_ecr_dkr_id" {
  description = "ECR DKR VPC Endpoint ID"
  value       = try(aws_vpc_endpoint.ecr_dkr[0].id, "")
}

output "vpc_endpoint_logs_id" {
  description = "CloudWatch Logs VPC Endpoint ID"
  value       = try(aws_vpc_endpoint.logs[0].id, "")
}

output "vpc_endpoint_secrets_manager_id" {
  description = "Secrets Manager VPC Endpoint ID"
  value       = try(aws_vpc_endpoint.secrets_manager[0].id, "")
}

output "vpc_flow_logs_id" {
  description = "VPC Flow Logs ID"
  value       = try(aws_flow_log.main[0].id, "")
}

output "vpc_flow_logs_group_name" {
  description = "VPC Flow Logs CloudWatch Log Group名"
  value       = try(aws_cloudwatch_log_group.vpc_flow_logs[0].name, "")
}

# S3関連の出力（第9回で追加）
output "frontend_s3_bucket_name" {
  description = "フロントエンド用S3バケット名"
  value       = aws_s3_bucket.frontend.id
}

output "frontend_s3_bucket_arn" {
  description = "フロントエンド用S3バケットARN"
  value       = aws_s3_bucket.frontend.arn
}

output "frontend_s3_bucket_domain_name" {
  description = "S3バケットのドメイン名"
  value       = aws_s3_bucket.frontend.bucket_domain_name
}

# CloudFront関連の出力
output "cloudfront_distribution_id" {
  description = "CloudFrontディストリビューションID"
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_distribution_arn" {
  description = "CloudFrontディストリビューションARN"
  value       = aws_cloudfront_distribution.frontend.arn
}

output "cloudfront_distribution_domain_name" {
  description = "CloudFrontディストリビューションのドメイン名"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "cloudfront_oac_id" {
  description = "CloudFront OAC ID"
  value       = aws_cloudfront_origin_access_control.frontend.id
}

# WAF関連の出力（第10回で追加）
output "waf_web_acl_id" {
  description = "WAF WebACL ID"
  value       = try(aws_wafv2_web_acl.main[0].id, "")
}

output "waf_web_acl_arn" {
  description = "WAF WebACL ARN"
  value       = try(aws_wafv2_web_acl.main[0].arn, "")
}

# セキュリティ設定の確認用
output "cors_allowed_origins" {
  description = "CORS許可されているオリジン"
  value = concat(
    ["https://${aws_cloudfront_distribution.frontend.domain_name}"],
    var.allowed_origins
  )
}

# 監視関連の出力 （第11回で追加）
output "cloudwatch_dashboard_url" {
  description = "CloudWatch Dashboard URL"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "xray_service_map_url" {
  description = "X-Ray Service Map URL"
  value       = var.enable_xray_tracing ? "https://console.aws.amazon.com/xray/home?region=${var.aws_region}#/service-map" : ""
}

output "sns_topic_arn" {
  description = "SNS Topic ARN for alarms"
  value       = aws_sns_topic.alarms.arn
}

output "alb_logs_bucket" {
  description = "ALB Access Logs S3 Bucket"
  value       = var.enable_alb_access_logs ? aws_s3_bucket.alb_logs[0].id : ""
}

# CI/CD関連の出力(第12回で追加)
output "github_actions_role_arn" {
  description = "GitHub Actions用IAMロールARN"
  value       = var.enable_github_oidc ? aws_iam_role.github_actions[0].arn : ""
}

output "artifacts_bucket_name" {
  description = "アーティファクト保存用S3バケット名"
  value       = aws_s3_bucket.artifacts.id
}