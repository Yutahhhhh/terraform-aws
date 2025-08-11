# プロジェクト設定
environment  = "dev"

# AWS設定
aws_region         = "ap-northeast-1"
availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]

# ネットワーク設定
vpc_cidr = "10.0.0.0/16"

# NAT Gateway設定（学習用途では false に設定してコストを削減）
# 本格的にプライベートサブネットからのアウトバウンド通信が必要な場合は true に設定
enable_nat_gateway = false

# CloudFrontのドメインは自動的に追加されるため、追加のオリジンのみ指定
allowed_origins = [
  # "https://example.com"  # カスタムドメインを使用する場合
]

# WAFを無効化
enable_waf = false

# APIレート制限（5分間）
api_rate_limit = 2000

# セキュリティヘッダーを有効化
enable_security_headers = true

# ALBアクセスログを有効化
enable_alb_access_logs = true

# X-Rayトレーシングを有効化
enable_xray_tracing = true

# アラーム閾値
cpu_utilization_threshold    = 80
memory_utilization_threshold = 80
error_rate_threshold        = 5