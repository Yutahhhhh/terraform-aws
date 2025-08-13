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

variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

# ECS設定
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

variable "desired_count" {
  description = "実行するタスク数"
  type        = number
  default     = 2
}

variable "container_port" {
  description = "コンテナポート番号"
  type        = number
  default     = 3000
}

# Auto Scaling設定
variable "min_capacity" {
  description = "最小タスク数"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "最大タスク数"
  type        = number
  default     = 10
}

variable "cpu_target_value" {
  description = "CPU使用率の目標値（%）"
  type        = number
  default     = 50
}

variable "memory_target_value" {
  description = "メモリ使用率の目標値（%）"
  type        = number
  default     = 70
}

variable "scale_in_cooldown" {
  description = "スケールイン後のクールダウン時間（秒）"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "スケールアウト後のクールダウン時間（秒）"
  type        = number
  default     = 60
}

# スケジュールベースのスケーリング設定
variable "enable_scheduled_scaling" {
  description = "スケジュールベースのスケーリングを有効にするか"
  type        = bool
  default     = false
}

variable "business_hours_min_capacity" {
  description = "営業時間中の最小タスク数"
  type        = number
  default     = 3
}

variable "business_hours_max_capacity" {
  description = "営業時間中の最大タスク数"
  type        = number
  default     = 10
}

variable "off_hours_min_capacity" {
  description = "営業時間外の最小タスク数"
  type        = number
  default     = 1
}

variable "off_hours_max_capacity" {
  description = "営業時間外の最大タスク数"
  type        = number
  default     = 3
}

# 外部リソース参照
variable "private_subnet_ids" {
  description = "プライベートサブネットIDのリスト"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ECS用セキュリティグループID"
  type        = string
}

variable "target_group_arn" {
  description = "ALBターゲットグループARN"
  type        = string
}


variable "db_secret_arn" {
  description = "データベース認証情報のSecrets Manager ARN"
  type        = string
}

# アプリケーション設定
variable "allowed_origins" {
  description = "CORS許可するオリジンのリスト"
  type        = list(string)
  default     = []
}

variable "enable_security_headers" {
  description = "セキュリティヘッダーを有効にするかどうか"
  type        = bool
  default     = true
}

variable "enable_xray_tracing" {
  description = "X-Rayトレーシングを有効にするか"
  type        = bool
  default     = true
}
