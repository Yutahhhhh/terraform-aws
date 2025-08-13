output "alb_security_group_id" {
  description = "ALB用セキュリティグループID"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ECS用セキュリティグループID"
  value       = aws_security_group.ecs.id
}

output "rds_security_group_id" {
  description = "RDS用セキュリティグループID"
  value       = aws_security_group.rds.id
}

output "vpc_endpoint_security_group_id" {
  description = "VPCエンドポイント用セキュリティグループID"
  value       = var.enable_vpc_endpoints ? aws_security_group.vpc_endpoint[0].id : null
}

output "alb_security_group_arn" {
  description = "ALB用セキュリティグループARN"
  value       = aws_security_group.alb.arn
}

output "ecs_security_group_arn" {
  description = "ECS用セキュリティグループARN"
  value       = aws_security_group.ecs.arn
}

output "rds_security_group_arn" {
  description = "RDS用セキュリティグループARN"
  value       = aws_security_group.rds.arn
}

output "database_security_group_id" {
  description = "データベース用セキュリティグループID（RDSと同じ）"
  value       = aws_security_group.rds.id
}
