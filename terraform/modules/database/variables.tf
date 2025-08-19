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

# ネットワーク設定
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "プライベートサブネットIDのリスト"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ECS用セキュリティグループID"
  type        = string
}

# データベース設定
variable "db_engine_version" {
  description = "PostgreSQLのバージョン"
  type        = string
  default     = "15.8"
}

variable "db_instance_class" {
  description = "RDSインスタンスクラス"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDSストレージサイズ(GB)"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "マスターユーザー名"
  type        = string
  default     = "postgres"
}

variable "multi_az" {
  description = "Multi-AZを有効にするかどうか"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "バックアップ保持期間（日）"
  type        = number
  default     = 7
}

# Performance Insights設定
variable "enable_performance_insights" {
  description = "Performance Insightsを有効にするか"
  type        = bool
  default     = false
}

variable "performance_insights_retention" {
  description = "Performance Insightsデータ保持期間（日）"
  type        = number
  default     = 7
  validation {
    condition     = contains([7, 731], var.performance_insights_retention)
    error_message = "Performance Insightsの保持期間は7日または731日である必要があります。"
  }
}

# RDS Proxy設定
variable "enable_rds_proxy" {
  description = "RDS Proxyを有効にするか"
  type        = bool
  default     = false
}

# セキュリティ設定
variable "enable_deletion_protection" {
  description = "削除保護を有効にするか"
  type        = bool
  default     = false
}

variable "secrets_recovery_window_days" {
  description = "Secrets Manager削除時の復旧期間（日）"
  type        = number
  default     = 0
  validation {
    condition     = var.secrets_recovery_window_days >= 0 && var.secrets_recovery_window_days <= 30
    error_message = "復旧期間は0から30日の間で設定してください。"
  }
}

variable "skip_final_snapshot" {
  description = "削除時の最終スナップショットをスキップするか"
  type        = bool
  default     = true
}
