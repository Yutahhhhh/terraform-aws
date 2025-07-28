# プロジェクト設定
environment  = "dev"

# AWS設定
aws_region         = "ap-northeast-1"
availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]

# ネットワーク設定
vpc_cidr = "10.0.0.0/16"

# NAT Gateway設定（学習用途では false に設定してコストを削減）
# 本格的にプライベートサブネットからのアウトバウンド通信が必要な場合は true に設定
enable_nat_gateway = true
