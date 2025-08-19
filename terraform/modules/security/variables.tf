variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名（dev/stg/prod）"
  type        = string
}

variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

# VPC関連（既存のセキュリティモジュールで必要）
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPCのCIDRブロック"
  type        = string
}

variable "enable_vpc_endpoints" {
  description = "VPCエンドポイントを有効にするか"
  type        = bool
  default     = false
}

variable "app_port" {
  description = "アプリケーションポート番号"
  type        = number
  default     = 3000
}

# WAF関連
variable "enable_waf" {
  description = "WAFを有効にするか"
  type        = bool
  default     = false
}

variable "waf_rate_limit" {
  description = "WAF rate limit per 5 minutes"
  type        = number
  default     = 2000
}

variable "allowed_countries" {
  description = "List of allowed country codes"
  type        = list(string)
  default     = []
}

variable "alb_arn" {
  description = "ALB ARN for WAF association"
  type        = string
  default     = ""
}

# GuardDuty関連
variable "enable_guardduty" {
  description = "GuardDutyを有効にするか"
  type        = bool
  default     = false
}

variable "guardduty_finding_frequency" {
  description = "GuardDuty finding publishing frequency"
  type        = string
  default     = "FIFTEEN_MINUTES"
}

variable "guardduty_severity_threshold" {
  description = "GuardDuty severity threshold for notifications"
  type        = number
  default     = 4
}

variable "enable_s3_protection" {
  description = "Enable S3 protection in GuardDuty"
  type        = bool
  default     = true
}

variable "enable_malware_protection" {
  description = "Enable malware protection in GuardDuty"
  type        = bool
  default     = false
}

variable "alarm_sns_topic_arn" {
  description = "SNS Topic ARN for alarms"
  type        = string
  default     = ""
}

# Config関連
variable "enable_config" {
  description = "AWS Configを有効にするか"
  type        = bool
  default     = false
}

variable "enable_rds" {
  description = "RDSが有効か（Config RDSルール用）"
  type        = bool
  default     = false
}

# セキュリティグループ関連
variable "allowed_cidr_blocks" {
  description = "Allowed CIDR blocks for ALB access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_security_group_id" {
  description = "ALB Security Group ID"
  type        = string
  default     = ""
}

variable "ecs_security_group_id" {
  description = "ECS Security Group ID"
  type        = string
  default     = ""
}

variable "rds_security_group_id" {
  description = "RDS Security Group ID"
  type        = string
  default     = ""
}

# IAM関連
variable "ecs_task_role_id" {
  description = "ECS Task Role ID"
  type        = string
  default     = ""
}

variable "app_bucket_arn" {
  description = "Application S3 Bucket ARN"
  type        = string
  default     = ""
}

variable "log_group_arn" {
  description = "CloudWatch Log Group ARN"
  type        = string
  default     = ""
}