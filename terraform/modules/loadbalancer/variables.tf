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

variable "public_subnet_ids" {
  description = "パブリックサブネットIDのリスト"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB用セキュリティグループID"
  type        = string
}

# ターゲットグループ設定
variable "target_port" {
  description = "ターゲットポート番号"
  type        = number
  default     = 3000
}

variable "deregistration_delay" {
  description = "ターゲット登録解除の遅延時間（秒）"
  type        = number
  default     = 60
}

# ヘルスチェック設定
variable "health_check_path" {
  description = "ヘルスチェックパス"
  type        = string
  default     = "/health"
}

variable "health_check_healthy_threshold" {
  description = "正常判定に必要な連続成功回数"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "異常判定に必要な連続失敗回数"
  type        = number
  default     = 2
}

variable "health_check_timeout" {
  description = "ヘルスチェックタイムアウト（秒）"
  type        = number
  default     = 5
}

variable "health_check_interval" {
  description = "ヘルスチェック間隔（秒）"
  type        = number
  default     = 30
}

variable "health_check_matcher" {
  description = "ヘルスチェック成功時のHTTPステータスコード"
  type        = string
  default     = "200"
}

# HTTPS設定
variable "enable_https" {
  description = "HTTPS通信を有効にするか"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "SSL証明書のARN"
  type        = string
  default     = null
}

variable "ssl_policy" {
  description = "SSL/TLSポリシー"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

# API設定
variable "api_path_patterns" {
  description = "APIパスパターンのリスト"
  type        = list(string)
  default     = ["/api/*", "/health"]
}

variable "enable_cors" {
  description = "CORS Preflightリクエストの処理を有効にするか"
  type        = bool
  default     = true
}

# アクセスログ設定
variable "enable_access_logs" {
  description = "ALBアクセスログを有効にするか"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "アクセスログ保存用S3バケット名"
  type        = string
  default     = null
}

# X-Ray設定
variable "enable_xray_tracing" {
  description = "X-Rayトレーシングを有効にするか"
  type        = bool
  default     = false
}

# セキュリティ設定
variable "enable_deletion_protection" {
  description = "削除保護を有効にするか"
  type        = bool
  default     = false
}
