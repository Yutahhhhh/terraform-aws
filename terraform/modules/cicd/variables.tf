variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名 (dev, stg, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWSリージョン"
  type        = string
}

variable "common_tags" {
  description = "共通タグ"
  type        = map(string)
  default     = {}
}

# GitHub OIDC関連
variable "enable_github_oidc" {
  description = "GitHub OIDCを有効にするか"
  type        = bool
  default     = false
}

variable "github_repository" {
  description = "GitHubリポジトリ名 (owner/repo形式)"
  type        = string
  default     = ""
}

# ECR関連
variable "ecr_repository_arn" {
  description = "ECRリポジトリのARN"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECRリポジトリのURL"
  type        = string
}

# ECS関連
variable "ecs_cluster_arn" {
  description = "ECSクラスターのARN"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECSクラスター名"
  type        = string
}

variable "ecs_service_arn" {
  description = "ECSサービスのARN"
  type        = string
}

variable "ecs_service_name" {
  description = "ECSサービス名"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ECS実行ロールのARN"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ECSタスクロールのARN"
  type        = string
}

# S3関連
variable "frontend_bucket_arn" {
  description = "フロントエンド用S3バケットのARN"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "アーティファクト用S3バケット名"
  type        = string
}

variable "artifacts_bucket_arn" {
  description = "アーティファクト用S3バケットのARN"
  type        = string
}

# CloudFront関連
variable "cloudfront_distribution_arn" {
  description = "CloudFront DistributionのARN"
  type        = string
}

# アーティファクト関連
variable "artifact_retention_days" {
  description = "アーティファクトの保持日数"
  type        = number
  default     = 30
}
