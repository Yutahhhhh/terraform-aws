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