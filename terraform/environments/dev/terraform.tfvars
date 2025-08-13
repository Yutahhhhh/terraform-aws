# プロジェクト設定
# project_name = "" 環境変数(TF_VAR_project_name)で設定しているが、環境別で個別指定の場合はコメントアウト解除
# environment = "dev" # variables.tfで定義されている環境名（dev/stg/prod）に合わせて設定

# 環境別機能有効化設定
# ========================================

# インフラストラクチャ
enable_rds         = true   # RDSデータベースを有効化（学習目的）
enable_nat_gateway = false  # NAT Gatewayを無効化（コスト削減）

# セキュリティ・監視
enable_waf                  = false # WAFを無効化（開発環境）
enable_vpc_endpoints        = true  # VPCエンドポイントを有効化（NAT Gateway無効のため必須）
enable_vpc_flow_logs        = false # VPC Flow Logsを無効化（コスト削減）
enable_alb_access_logs      = false # ALBアクセスログを無効化（コスト削減）
enable_xray_tracing         = false # X-Rayトレーシングを無効化（コスト削減）
enable_cloudfront_logging   = false # CloudFrontログを無効化（コスト削減）

# アラーム・監視
enable_cpu_alarm            = false # CPUアラームを無効化（開発環境）
enable_memory_alarm         = false # メモリアラームを無効化（開発環境）
enable_unhealthy_host_alarm = false # 異常ホストアラームを無効化（開発環境）

# CI/CD
# github_repository = "" # GitHubリポジトリ 環境変数(TF_VAR_github_repository)で設定しているが、環境別で個別指定の場合はコメントアウト解除

# その他の環境固有設定
# ========================================
allowed_origins = [] # CORS許可オリジン（実際の値を設定）
# alarm_email     = "" # アラーム通知先メール 環境変数(TF_VAR_alarm_email)で設定しているが、環境別で個別指定の場合はコメントアウト解除

# SSL証明書（オプション）
alb_certificate_arn      = ""
frontend_certificate_arn = ""
frontend_domain_name     = ""
