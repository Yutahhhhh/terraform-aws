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

# CloudFront関連
variable "frontend_domain_name" {
  description = "フロントエンドのドメイン名（オプション）"
  type        = string
  default     = ""
}

variable "frontend_certificate_arn" {
  description = "CloudFront用のSSL証明書ARN（us-east-1リージョン）"
  type        = string
  default     = ""
}

variable "enable_cloudfront_logging" {
  description = "CloudFrontのアクセスログを有効にするか"
  type        = bool
  default     = false
}

variable "cloudfront_price_class" {
  description = "CloudFrontの価格クラス"
  type        = string
  default     = "PriceClass_100"  # 日本を指定してコスト削減
}

# CORS設定
variable "allowed_origins" {
  description = "CORS許可するオリジンのリスト"
  type        = list(string)
  default     = []  # 実際の値はterraform.tfvarsで設定
}

variable "enable_waf" {
  description = "WAFを有効にするかどうか"
  type        = bool
  default     = true
}

variable "api_rate_limit" {
  description = "APIレート制限（5分間のリクエスト数）"
  type        = number
  default     = 2000
}

variable "enable_security_headers" {
  description = "セキュリティヘッダーを有効にするかどうか"
  type        = bool
  default     = true
}

# ALB SSL証明書関連
variable "alb_certificate_arn" {
  description = "ALB用のSSL証明書ARN（リージョン内）"
  type        = string
  default     = ""
}

variable "alb_domain_name" {
  description = "ALBのドメイン名（オプション）"
  type        = string
  default     = ""
}

variable "enable_https_redirect" {
  description = "HTTPからHTTPSへのリダイレクトを有効にするかどうか"
  type        = bool
  default     = true
}

# 監視とアラーム関連
variable "enable_alb_access_logs" {
  description = "ALBアクセスログを有効にするか"
  type        = bool
  default     = true
}

variable "enable_xray_tracing" {
  description = "X-Rayトレーシングを有効にするか"
  type        = bool
  default     = true
}

variable "alarm_email" {
  description = "アラーム通知先のメールアドレス"
  type        = string
  default     = ""
}

variable "cpu_utilization_threshold" {
  description = "CPU使用率のアラーム閾値（%）"
  type        = number
  default     = 80
}

variable "memory_utilization_threshold" {
  description = "メモリ使用率のアラーム閾値（%）"
  type        = number
  default     = 80
}

variable "error_rate_threshold" {
  description = "エラー率のアラーム閾値（%）"
  type        = number
  default     = 5
}