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

# VPC関連
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "private_subnet_ids" {
  description = "プライベートサブネットIDのリスト"
  type        = list(string)
}

variable "route_table_ids" {
  description = "ルートテーブルIDのリスト"
  type        = list(string)
}

# VPC Endpoints関連
variable "enable_vpc_endpoints" {
  description = "VPCエンドポイントを有効にするか"
  type        = bool
  default     = false
}

variable "enable_xray_tracing" {
  description = "X-Rayトレーシングを有効にするか"
  type        = bool
  default     = false
}

# VPC Flow Logs関連
variable "enable_vpc_flow_logs" {
  description = "VPCフローログを有効にするか"
  type        = bool
  default     = false
}

variable "flow_logs_retention_days" {
  description = "フローログの保持日数"
  type        = number
  default     = 14
}
