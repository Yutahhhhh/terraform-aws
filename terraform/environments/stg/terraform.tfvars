# プロジェクト設定
# project_name = "" # 環境変数(TF_VAR_project_name)で設定しているが、環境別で個別指定の場合はコメントアウト解除
# environment = "stg" # variables.tfで定義されている環境名（dev/stg/prod）に合わせて設定

# 環境別機能有効化設定
# ========================================

# インフラストラクチャ
enable_rds         = true # RDSデータベースを有効化
enable_nat_gateway = true # NAT Gatewayを有効化（本格的なテスト環境）

# セキュリティ・監視
enable_waf                  = true  # WAFを有効化（セキュリティテスト）
enable_vpc_endpoints        = false # VPCエンドポイントを無効化（NAT Gateway有効のため不要）
enable_vpc_flow_logs        = true  # VPC Flow Logsを有効化
enable_alb_access_logs      = true  # ALBアクセスログを有効化
enable_xray_tracing         = true  # X-Rayトレーシングを有効化
enable_cloudfront_logging   = true  # CloudFrontログを有効化

# アラーム・監視
enable_cpu_alarm            = true # CPUアラームを有効化
enable_memory_alarm         = true # メモリアラームを有効化
enable_unhealthy_host_alarm = true # 異常ホストアラームを有効化

# CI/CD
# github_repository = "" 環境変数(TF_VAR_github_repository)で設定しているが、環境別で個別指定の場合はコメントアウト解除

# その他の環境固有設定
# ========================================
allowed_origins = [] # CORS許可オリジン（実際の値を設定）
# alarm_email     = "" # アラーム通知先メール 環境変数(TF_VAR_alarm_email)で設定しているが、環境別で個別指定の場合はコメントアウト解除

# SSL証明書（オプション）
alb_certificate_arn      = ""
frontend_certificate_arn = ""
frontend_domain_name     = ""
