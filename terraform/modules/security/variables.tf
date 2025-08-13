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

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPCのCIDRブロック"
  type        = string
}

variable "app_port" {
  description = "アプリケーションポート番号"
  type        = number
  default     = 3000
}

variable "enable_vpc_endpoints" {
  description = "VPCエンドポイントを有効にするか"
  type        = bool
  default     = true
}
