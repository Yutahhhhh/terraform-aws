variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名"
  type        = string
  default     = "prod"
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
  default     = "10.2.0.0/16"
}

variable "enable_nat_gateway" {
  description = "NAT Gatewayを有効にするかどうか（学習用途ではfalseに設定してコストを削減）"
  type        = bool
  default     = true
}

variable "db_instance_class" {
  description = "RDSインスタンスクラス"
  type        = string
  default     = "db.t3.medium"  # 本番環境用
}

variable "db_allocated_storage" {
  description = "RDSストレージサイズ(GB)"
  type        = number
  default     = 100
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
  default     = true  # 本番環境では高可用性のためtrue
}

# ECS、コンテナ関連
variable "task_cpu" {
  description = "タスクのCPU単位（256 = 0.25 vCPU）"
  type        = string
  default     = "1024"
}

variable "task_memory" {
  description = "タスクのメモリ（MB）"
  type        = string
  default     = "2048"
}

variable "app_count" {
  description = "実行するタスク数"
  type        = number
  default     = 3
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
  default     = 30
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
  default     = true
}

variable "cloudfront_price_class" {
  description = "CloudFrontの価格クラス"
  type        = string
  default     = "PriceClass_All"  # 本番環境では全世界対応
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
  default     = 5000
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
  default     = 60
}

variable "memory_utilization_threshold" {
  description = "メモリ使用率のアラーム閾値（%）"
  type        = number
  default     = 60
}

variable "error_rate_threshold" {
  description = "エラー率のアラーム閾値（%）"
  type        = number
  default     = 1
}

# CI/CD関連
variable "enable_github_oidc" {
  description = "GitHub Actions OIDCを有効にするか"
  type        = bool
  default     = true
}

variable "artifact_retention_days" {
  description = "build artifact の保持期間"
  type        = number
  default     = 90
}

variable "github_repository" {
  description = "GitHubリポジトリ（例: username/repository-name）"
  type        = string
  default     = ""
}

# 追加の変数定義
variable "public_subnet_cidrs" {
  description = "パブリックサブネットのCIDRブロック"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "プライベートサブネットのCIDRブロック"
  type        = list(string)
  default     = ["10.2.10.0/24", "10.2.20.0/24"]
}

variable "single_nat_gateway" {
  description = "単一のNAT Gatewayを使用するか"
  type        = bool
  default     = false  # 本番環境では冗長化のためfalse
}

variable "enable_nacl" {
  description = "Network ACLを有効にするか"
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "許可するCIDRブロック"
  type        = list(string)
  default     = ["203.0.113.0/24"]  # 本番環境では特定のIPアドレスからのアクセスを許可
}

variable "enable_s3_versioning" {
  description = "S3バケットのバージョニングを有効にするか"
  type        = bool
  default     = true
}

variable "enable_s3_logging" {
  description = "S3アクセスログを有効にするか"
  type        = bool
  default     = true
}

variable "enable_rds" {
  description = "RDSを有効にするか"
  type        = bool
  default     = true
}

variable "enable_rds_proxy" {
  description = "RDS Proxyを有効にするか"
  type        = bool
  default     = true  # 本番環境では接続プールのためtrue
}

variable "enable_performance_insights" {
  description = "Performance Insightsを有効にするか"
  type        = bool
  default     = true
}

variable "db_max_allocated_storage" {
  description = "RDSの最大ストレージサイズ(GB)"
  type        = number
  default     = 1000
}

variable "db_name" {
  description = "データベース名"
  type        = string
  default     = "myapp"
}

variable "db_password" {
  description = "データベースパスワード"
  type        = string
  sensitive   = true
  default     = ""
}

variable "backup_retention_period" {
  description = "バックアップ保持期間（日）"
  type        = number
  default     = 30
}

variable "backup_window" {
  description = "バックアップウィンドウ"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "メンテナンスウィンドウ"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "deletion_protection" {
  description = "削除保護を有効にするか"
  type        = bool
  default     = true  # 本番環境では削除保護を有効
}

variable "skip_final_snapshot" {
  description = "最終スナップショットをスキップするか"
  type        = bool
  default     = false
}

variable "enable_auto_scaling" {
  description = "Auto Scalingを有効にするか"
  type        = bool
  default     = true
}

variable "enable_service_connect" {
  description = "ECS Service Connectを有効にするか"
  type        = bool
  default     = false
}

variable "ecr_image_tag_mutability" {
  description = "ECRイメージタグの可変性"
  type        = string
  default     = "IMMUTABLE"  # 本番環境では不変
}

variable "ecr_scan_on_push" {
  description = "プッシュ時のイメージスキャンを有効にするか"
  type        = bool
  default     = true
}

variable "ecs_task_cpu" {
  description = "ECSタスクのCPU"
  type        = string
  default     = "1024"
}

variable "ecs_task_memory" {
  description = "ECSタスクのメモリ"
  type        = string
  default     = "2048"
}

variable "ecs_desired_count" {
  description = "ECSサービスの希望タスク数"
  type        = number
  default     = 3
}

variable "ecs_min_capacity" {
  description = "Auto Scalingの最小キャパシティ"
  type        = number
  default     = 2
}

variable "ecs_max_capacity" {
  description = "Auto Scalingの最大キャパシティ"
  type        = number
  default     = 10
}

variable "container_port" {
  description = "コンテナのポート番号"
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "ヘルスチェックのパス"
  type        = string
  default     = "/health"
}

variable "log_retention_days" {
  description = "ログの保持日数"
  type        = number
  default     = 30
}

variable "enable_alb_deletion_protection" {
  description = "ALBの削除保護を有効にするか"
  type        = bool
  default     = true  # 本番環境では削除保護を有効
}

variable "certificate_arn" {
  description = "SSL証明書のARN"
  type        = string
  default     = ""
}

variable "health_check_interval" {
  description = "ヘルスチェックの間隔（秒）"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "ヘルスチェックのタイムアウト（秒）"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "正常と判定するヘルスチェック回数"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "異常と判定するヘルスチェック回数"
  type        = number
  default     = 2
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
  default     = true  # 本番環境ではtrue
}

variable "enable_cicd" {
  description = "CI/CDパイプラインを有効にするか"
  type        = bool
  default     = true
}

# スケジュールスケーリング設定
variable "enable_scheduled_scaling" {
  description = "スケジュールベースのスケーリングを有効にするか"
  type        = bool
  default     = true  # 本番環境ではデフォルトで有効
}

# データベースセキュリティ設定
variable "enable_deletion_protection" {
  description = "削除保護を有効にするか"
  type        = bool
  default     = true  # 本番環境ではデフォルトで有効
}

variable "secrets_recovery_window_days" {
  description = "Secrets Manager削除時の復旧期間（日）"
  type        = number
  default     = 30  # 本番環境では30日
  validation {
    condition     = var.secrets_recovery_window_days >= 0 && var.secrets_recovery_window_days <= 30
    error_message = "復旧期間は0から30日の間で設定してください。"
  }
}

variable "skip_final_snapshot" {
  description = "削除時の最終スナップショットをスキップするか"
  type        = bool
  default     = false  # 本番環境ではスナップショットを作成
}

# セキュリティ機能の有効化フラグ
variable "enable_guardduty" {
  description = "GuardDutyを有効にするか"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "AWS Configを有効にするか"
  type        = bool
  default     = true
}

# WAF関連の設定
variable "waf_rate_limit" {
  description = "WAF rate limit per 5 minutes"
  type        = number
  default     = 2000
}

variable "allowed_countries" {
  description = "List of allowed country codes"
  type        = list(string)
  default     = ["JP"]
}

# GuardDuty関連の設定
variable "guardduty_finding_frequency" {
  description = "GuardDuty finding publishing frequency"
  type        = string
  default     = "FIFTEEN_MINUTES"
  validation {
    condition = contains([
      "FIFTEEN_MINUTES",
      "ONE_HOUR",
      "SIX_HOURS"
    ], var.guardduty_finding_frequency)
    error_message = "有効な頻度を選択してください"
  }
}

variable "guardduty_severity_threshold" {
  description = "GuardDuty severity threshold for notifications (1-8, 1=lowest, 8=highest)"
  type        = number
  default     = 4
  validation {
    condition     = var.guardduty_severity_threshold >= 1 && var.guardduty_severity_threshold <= 8
    error_message = "脅威レベルは1から8の間で設定してください"
  }
}

variable "enable_s3_protection" {
  description = "Enable S3 protection in GuardDuty"
  type        = bool
  default     = true
}

variable "enable_malware_protection" {
  description = "Enable malware protection in GuardDuty"
  type        = bool
  default     = true
}
