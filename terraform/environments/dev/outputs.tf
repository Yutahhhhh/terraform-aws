# Network outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.network.private_subnet_ids
}

# Load Balancer outputs
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.loadbalancer.alb_dns_name
}

output "alb_zone_id" {
  description = "ALB Zone ID"
  value       = module.loadbalancer.alb_zone_id
}

# CloudFront outputs
output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = module.cdn.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront Domain Name"
  value       = module.cdn.cloudfront_domain_name
}

# ECS outputs
output "ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = module.compute.ecs_cluster_name
}

output "ecs_service_name" {
  description = "ECS Service Name"
  value       = module.compute.ecs_service_name
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = module.compute.ecr_repository_url
}

# Database outputs
output "db_endpoint" {
  description = "RDS endpoint"
  value       = var.enable_rds && length(module.database) > 0 ? module.database[0].db_instance_endpoint : null
}

output "db_port" {
  description = "RDS port"
  value       = var.enable_rds && length(module.database) > 0 ? module.database[0].db_instance_port : null
}

# Storage outputs
output "frontend_bucket_id" {
  description = "Frontend S3 bucket ID"
  value       = module.storage.frontend_bucket_id
}

output "frontend_bucket_name" {
  description = "Frontend S3 bucket name"
  value       = module.storage.frontend_bucket_id
}

output "frontend_bucket_domain_name" {
  description = "Frontend S3 bucket domain name"
  value       = module.storage.frontend_bucket_regional_domain_name
}

# CI/CD outputs (条件付き)
output "github_actions_role_arn" {
  description = "GitHub Actions IAM Role ARN"
  value       = var.enable_cicd && var.github_repository != "" && length(module.cicd) > 0 ? module.cicd[0].github_actions_role_arn : null
}

output "github_actions_role_name" {
  description = "GitHub Actions IAM Role Name"
  value       = var.enable_cicd && var.github_repository != "" && length(module.cicd) > 0 ? module.cicd[0].github_actions_role_name : null
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC Provider ARN"
  value       = var.enable_cicd && var.github_repository != "" && length(module.cicd) > 0 ? module.cicd[0].github_oidc_provider_arn : null
}

output "artifacts_bucket_name" {
  description = "CI/CD artifacts bucket name"
  value       = var.enable_cicd && var.github_repository != "" && length(module.cicd) > 0 ? module.cicd[0].artifacts_bucket_name : null
}

# Monitoring outputs (条件付き)
output "sns_topic_arn" {
  description = "SNS Topic ARN for alarms"
  value       = (var.enable_cpu_alarm || var.enable_memory_alarm || var.enable_unhealthy_host_alarm) && length(module.monitoring) > 0 ? module.monitoring[0].sns_topic_arn : null
}
