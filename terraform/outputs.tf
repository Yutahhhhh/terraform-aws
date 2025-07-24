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