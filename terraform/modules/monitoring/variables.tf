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

# Dashboard関連
variable "ecs_log_group_name" {
  description = "ECSログループ名"
  type        = string
}

# アラーム関連
variable "alarm_email" {
  description = "アラーム通知先メールアドレス"
  type        = string
  default     = ""
}

variable "enable_cpu_alarm" {
  description = "CPU使用率アラームを有効にするか"
  type        = bool
  default     = true
}

variable "enable_memory_alarm" {
  description = "メモリ使用率アラームを有効にするか"
  type        = bool
  default     = true
}

variable "enable_unhealthy_host_alarm" {
  description = "異常ホストアラームを有効にするか"
  type        = bool
  default     = true
}

variable "cpu_utilization_threshold" {
  description = "CPU使用率のしきい値"
  type        = number
  default     = 80
}

variable "memory_utilization_threshold" {
  description = "メモリ使用率のしきい値"
  type        = number
  default     = 80
}

# ECS関連
variable "ecs_cluster_name" {
  description = "ECSクラスター名"
  type        = string
}

variable "ecs_service_name" {
  description = "ECSサービス名"
  type        = string
}

variable "ecs_task_role_name" {
  description = "ECSタスクロール名"
  type        = string
}

# ALB関連
variable "target_group_arn_suffix" {
  description = "ターゲットグループのARNサフィックス"
  type        = string
}

variable "load_balancer_arn_suffix" {
  description = "ロードバランサーのARNサフィックス"
  type        = string
}

# X-Ray関連
variable "enable_xray_tracing" {
  description = "X-Rayトレーシングを有効にするか"
  type        = bool
  default     = false
}

# ALBアクセスログ関連
variable "enable_alb_access_logs" {
  description = "ALBアクセスログを有効にするか"
  type        = bool
  default     = false
}
