output "github_oidc_provider_arn" {
  description = "GitHub OIDC Provider ARN"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arn" {
  description = "GitHub Actions IAM Role ARN"
  value       = var.enable_github_oidc ? aws_iam_role.github_actions[0].arn : null
}

output "github_actions_role_name" {
  description = "GitHub Actions IAM Role Name"
  value       = var.enable_github_oidc ? aws_iam_role.github_actions[0].name : null
}

output "artifacts_bucket_name" {
  description = "アーティファクト用S3バケット名"
  value       = var.artifacts_bucket_name
}

output "artifacts_bucket_arn" {
  description = "アーティファクト用S3バケットARN"
  value       = var.artifacts_bucket_arn
}

output "ecr_repository_url_parameter" {
  description = "ECRリポジトリURL Parameter Store名"
  value       = aws_ssm_parameter.ecr_repository_url.name
}

output "ecs_cluster_name_parameter" {
  description = "ECSクラスター名 Parameter Store名"
  value       = aws_ssm_parameter.ecs_cluster_name.name
}

output "ecs_service_name_parameter" {
  description = "ECSサービス名 Parameter Store名"
  value       = aws_ssm_parameter.ecs_service_name.name
}
