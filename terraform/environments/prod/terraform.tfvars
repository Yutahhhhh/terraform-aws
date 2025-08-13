# プロジェクト設定
# project_name = "" 環境変数(TF_VAR_project_name)で設定しているが、環境別で個別指定の場合はコメントアウト解除
# environment = "prod" # variables.tfで定義されている環境名（dev/stg/prod）に合わせて設定

# 環境別機能有効化設定
# ========================================

# インフラストラクチャ
enable_rds         = true # RDSデータベースを有効化
enable_nat_gateway = true # NAT Gatewayを有効化（本番環境では必須）

# セキュリティ・監視
enable_waf                  = true # WAFを有効化（本番環境では必須）
enable_vpc_endpoints        = true # VPCエンドポイントを有効化（セキュリティ強化）
enable_vpc_flow_logs        = true # VPC Flow Logsを有効化（監査・セキュリティ）
enable_alb_access_logs      = true # ALBアクセスログを有効化（監査・分析）
enable_xray_tracing         = true # X-Rayトレーシングを有効化（パフォーマンス監視）
enable_cloudfront_logging   = true # CloudFrontログを有効化（アクセス分析）

# アラーム・監視
enable_cpu_alarm            = true # CPUアラームを有効化（本番監視）
enable_memory_alarm         = true # メモリアラームを有効化（本番監視）
enable_unhealthy_host_alarm = true # 異常ホストアラームを有効化（本番監視）

# 本番環境固有設定
# ========================================
single_nat_gateway = false # 本番環境では冗長化のためfalse

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
