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
  default     = 1  # 開発環境では1つに削減
}

// VPCエンドポイント関連
variable "enable_vpc_endpoints" {
  description = "VPCエンドポイントを有効にするかどうか"
  type        = bool
  default     = false  # 開発環境ではコスト削減のためfalse
}

variable "enable_vpc_flow_logs" {
  description = "VPC Flow Logsを有効にするかどうか"
  type        = bool
  default     = false  # 開発環境ではfalse
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
  default     = false  # 開発環境ではfalse
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
  default     = false  # 開発環境では証明書なしでfalse
}

# 監視とアラーム関連
variable "enable_alb_access_logs" {
  description = "ALBアクセスログを有効にするか"
  type        = bool
  default     = false  # 開発環境ではfalse
}

variable "enable_xray_tracing" {
  description = "X-Rayトレーシングを有効にするか"
  type        = bool
  default     = false  # 開発環境ではfalse
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

# CI/CD関連
variable "enable_github_oidc" {
  description = "GitHub Actions OIDCを有効にするか"
  type        = bool
  default     = true
}

variable "artifact_retention_days" {
  description = "build artifact の保持期間"
  type        = number
  default     = 7  # 開発環境では短期間
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
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "プライベートサブネットのCIDRブロック"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "single_nat_gateway" {
  description = "単一のNAT Gatewayを使用するか"
  type        = bool
  default     = true
}

variable "enable_nacl" {
  description = "Network ACLを有効にするか"
  type        = bool
  default     = false  # 開発環境ではfalse
}

variable "allowed_cidr_blocks" {
  description = "許可するCIDRブロック"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_s3_versioning" {
  description = "S3バケットのバージョニングを有効にするか"
  type        = bool
  default     = false  # 開発環境ではfalse
}

variable "enable_s3_logging" {
  description = "S3アクセスログを有効にするか"
  type        = bool
  default     = false
}

variable "enable_rds" {
  description = "RDSを有効にするか"
  type        = bool
  default     = true
}

variable "enable_rds_proxy" {
  description = "RDS Proxyを有効にするか"
  type        = bool
  default     = false
}

variable "enable_performance_insights" {
  description = "Performance Insightsを有効にするか"
  type        = bool
  default     = false
}

variable "db_max_allocated_storage" {
  description = "RDSの最大ストレージサイズ(GB)"
  type        = number
  default     = 50  # 開発環境では小さく
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
  default     = 1  # 開発環境では最小
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
  default     = false
}

variable "skip_final_snapshot" {
  description = "最終スナップショットをスキップするか"
  type        = bool
  default     = true
}

variable "enable_auto_scaling" {
  description = "Auto Scalingを有効にするか"
  type        = bool
  default     = false  # 開発環境ではfalse
}

variable "enable_service_connect" {
  description = "ECS Service Connectを有効にするか"
  type        = bool
  default     = false
}

variable "ecr_image_tag_mutability" {
  description = "ECRイメージタグの可変性"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "プッシュ時のイメージスキャンを有効にするか"
  type        = bool
  default     = false  # 開発環境ではfalse
}

variable "ecs_task_cpu" {
  description = "ECSタスクのCPU"
  type        = string
  default     = "256"
}

variable "ecs_task_memory" {
  description = "ECSタスクのメモリ"
  type        = string
  default     = "512"
}

variable "ecs_desired_count" {
  description = "ECSサービスの希望タスク数"
  type        = number
  default     = 1  # 開発環境では1つ
}

variable "ecs_min_capacity" {
  description = "Auto Scalingの最小キャパシティ"
  type        = number
  default     = 1
}

variable "ecs_max_capacity" {
  description = "Auto Scalingの最大キャパシティ"
  type        = number
  default     = 3  # 開発環境では小さく
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
  default     = 7  # 開発環境では短期間
}

variable "enable_alb_deletion_protection" {
  description = "ALBの削除保護を有効にするか"
  type        = bool
  default     = false
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
  default     = false  # 開発環境ではfalse
}

variable "enable_memory_alarm" {
  description = "メモリ使用率アラームを有効にするか"
  type        = bool
  default     = false  # 開発環境ではfalse
}

variable "enable_unhealthy_host_alarm" {
  description = "異常ホストアラームを有効にするか"
  type        = bool
  default     = false  # 開発環境ではfalse
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
  default     = false  # 開発環境ではデフォルトで無効
}

# データベースセキュリティ設定
variable "enable_deletion_protection" {
  description = "削除保護を有効にするか"
  type        = bool
  default     = false  # 開発環境ではデフォルトで無効
}

variable "secrets_recovery_window_days" {
  description = "Secrets Manager削除時の復旧期間（日）"
  type        = number
  default     = 0  # 開発環境では即座に削除
  validation {
    condition     = var.secrets_recovery_window_days >= 0 && var.secrets_recovery_window_days <= 30
    error_message = "復旧期間は0から30日の間で設定してください。"
  }
}

# セキュリティ機能の有効化フラグ
variable "enable_guardduty" {
  description = "GuardDutyを有効にするか"
  type        = bool
  default     = false
}

variable "enable_config" {
  description = "AWS Configを有効にするか"
  type        = bool
  default     = false
}

# WAF関連の設定
variable "waf_rate_limit" {
  description = "WAF rate limit per 5 minutes"
  type        = number
  default     = 5000  # 開発環境のデフォルト値
}

variable "allowed_countries" {
  description = "List of allowed country codes"
  type        = list(string)
  default     = ["JP", "US"]  # 開発環境のデフォルト値
}

# GuardDuty関連の設定
variable "guardduty_finding_frequency" {
  description = "GuardDuty finding publishing frequency"
  type        = string
  default     = "ONE_HOUR"  # 開発環境のデフォルト値
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
  default     = 7  # 開発環境のデフォルト値
  validation {
    condition     = var.guardduty_severity_threshold >= 1 && var.guardduty_severity_threshold <= 8
    error_message = "脅威レベルは1から8の間で設定してください"
  }
}

variable "enable_s3_protection" {
  description = "Enable S3 protection in GuardDuty"
  type        = bool
  default     = false  # 開発環境のデフォルト値
}

variable "enable_malware_protection" {
  description = "Enable malware protection in GuardDuty"
  type        = bool
  default     = false  # 開発環境のデフォルト値
}
