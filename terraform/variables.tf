variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "availability_zones" {
  description = "使用するアベイラビリティゾーン"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "vpc_cidr" {
  description = "VPCのCIDRブロック"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  description = "NAT Gatewayを有効にするかどうか（学習用途ではfalseに設定してコストを削減）"
  type        = bool
  default     = false
}

variable "db_instance_class" {
  description = "RDSインスタンスクラス"
  type        = string
  default     = "db.t3.micro"  # 開発環境用の最小構成
}

variable "db_allocated_storage" {
  description = "RDSストレージサイズ(GB)"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "PostgreSQLのバージョン"
  type        = string
  default     = "15.8"
}

variable "db_username" {
  description = "マスターユーザー名"
  type        = string
  default     = "postgres"
}

variable "enable_db_multi_az" {
  description = "Multi-AZを有効にするかどうか"
  type        = bool
  default     = false  # 開発環境ではコスト削減のためfalse
}

# ECS、コンテナ関連
variable "task_cpu" {
  description = "タスクのCPU単位（256 = 0.25 vCPU）"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "タスクのメモリ（MB）"
  type        = string
  default     = "512"
}

variable "app_count" {
  description = "実行するタスク数"
  type        = number
  default     = 2
}

// VPCエンドポイント関連
variable "enable_vpc_endpoints" {
  description = "VPCエンドポイントを有効にするかどうか"
  type        = bool
  default     = true
}

variable "enable_vpc_flow_logs" {
  description = "VPC Flow Logsを有効にするかどうか"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "VPC Flow Logsの保持期間（日）"
  type        = number
  default     = 7
}