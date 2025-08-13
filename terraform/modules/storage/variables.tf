variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名（dev/stg/prod）"
  type        = string
  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "環境名はdev、stg、prodのいずれかである必要があります。"
  }
}

# フロントエンド設定
variable "enable_versioning" {
  description = "S3バケットのバージョニングを有効にするか"
  type        = bool
  default     = true
}

variable "cloudfront_distribution_arn" {
  description = "CloudFrontディストリビューションARN"
  type        = string
}

# ALBアクセスログ設定
variable "enable_alb_access_logs" {
  description = "ALBアクセスログを有効にするか"
  type        = bool
  default     = false
}

variable "alb_account_id" {
  description = "ALBサービスアカウントID（リージョン別）"
  type        = string
  default     = "582318560864"  # ap-northeast-1のALBアカウントID
}

variable "alb_logs_retention_days" {
  description = "ALBアクセスログの保持期間（日）"
  type        = number
  default     = 30
}

# CloudFrontログ設定
variable "enable_cloudfront_logging" {
  description = "CloudFrontアクセスログを有効にするか"
  type        = bool
  default     = false
}

variable "cloudfront_logs_retention_days" {
  description = "CloudFrontアクセスログの保持期間（日）"
  type        = number
  default     = 30
}

# CI/CD設定
variable "enable_cicd" {
  description = "CI/CDアーティファクト用バケットを作成するか"
  type        = bool
  default     = false
}

variable "artifacts_retention_days" {
  description = "CI/CDアーティファクトの保持期間（日）"
  type        = number
  default     = 30
}

# バックアップ設定
variable "enable_backup" {
  description = "バックアップ用バケットを作成するか"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "バックアップの保持期間（日）"
  type        = number
  default     = 2555  # 約7年
}
