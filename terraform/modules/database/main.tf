# Local Valuesで共通設定を定義
locals {
  common_tags = {
    Module      = "database"
    ManagedBy   = "terraform"
    Environment = var.environment
    Project     = var.project_name
  }
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  # Inbound from ECS only
  ingress {
    description     = "PostgreSQL from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  # No outbound rules needed for RDS

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-rds-sg"
    }
  )
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-db-subnet-group"
    }
  )
}

# ランダムパスワードの生成
resource "random_password" "db_password" {
  length  = 32
  special = true
  # RDSで使用できない文字を除外
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Secrets Manager Secret
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.project_name}-${var.environment}-db-credentials"

  # 削除時の復旧期間を環境別に設定
  recovery_window_in_days = var.secrets_recovery_window_days

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-db-credentials"
    }
  )
}

# Secret Version
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    dbname   = aws_db_instance.main.db_name
  })
}

# DB Parameter Group
resource "aws_db_parameter_group" "main" {
  name   = "${var.project_name}-${var.environment}-pg15"
  family = "postgres15"

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  parameter {
    name  = "log_statement"
    value = var.enable_performance_insights ? "all" : "none"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = var.enable_performance_insights ? "1000" : "-1"  # 1秒以上のクエリをログ出力
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-pg15"
    }
  )
}

# Performance Insights用KMSキー
resource "aws_kms_key" "rds" {
  count = var.enable_performance_insights ? 1 : 0

  description             = "${var.project_name}-${var.environment}-rds-pi-key"
  deletion_window_in_days = 10

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-rds-pi-key"
    }
  )
}

resource "aws_kms_alias" "rds" {
  count = var.enable_performance_insights ? 1 : 0

  name          = "alias/${var.project_name}-${var.environment}-rds-pi"
  target_key_id = aws_kms_key.rds[0].key_id
}

# Enhanced Monitoring用IAMロール
resource "aws_iam_role" "rds_monitoring" {
  count = var.enable_performance_insights ? 1 : 0

  name = "${var.project_name}-${var.environment}-rds-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-rds-monitoring"
    }
  )
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count = var.enable_performance_insights ? 1 : 0

  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-db"

  # エンジン設定
  engine         = "postgres"
  engine_version = var.db_engine_version

  # インスタンス設定
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_allocated_storage * 2  # 自動スケーリング上限

  # データベース設定
  db_name  = replace("${var.project_name}_${var.environment}_db", "-", "_")
  username = var.db_username
  password = random_password.db_password.result

  # ネットワーク設定
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  # 高可用性設定
  multi_az = var.multi_az

  # バックアップ設定
  backup_retention_period = var.backup_retention_period
  backup_window          = "03:00-04:00"  # UTC
  maintenance_window     = "sun:04:00-sun:05:00"  # UTC

  # パラメータグループ
  parameter_group_name = aws_db_parameter_group.main.name

  # Performance Insights設定
  enabled_cloudwatch_logs_exports       = ["postgresql"]
  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.enable_performance_insights ? var.performance_insights_retention : null
  performance_insights_kms_key_id      = var.enable_performance_insights ? aws_kms_key.rds[0].arn : null

  # Enhanced Monitoring
  monitoring_interval = var.enable_performance_insights ? 60 : 0
  monitoring_role_arn = var.enable_performance_insights ? aws_iam_role.rds_monitoring[0].arn : null

  # その他の設定
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.enable_deletion_protection

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-db"
    }
  )
}

# RDS Proxy（本番環境のみ）
resource "aws_db_proxy" "main" {
  count = var.enable_rds_proxy ? 1 : 0

  name                   = "${var.project_name}-${var.environment}-db-proxy"
  engine_family         = "POSTGRESQL"
  auth {
    auth_scheme = "SECRETS"
    secret_arn  = aws_secretsmanager_secret.db_credentials.arn
  }

  role_arn               = aws_iam_role.rds_proxy[0].arn
  vpc_subnet_ids         = var.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]

  idle_client_timeout = 1800

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-db-proxy"
    }
  )
}

# RDS Proxy Target Group
resource "aws_db_proxy_default_target_group" "main" {
  count = var.enable_rds_proxy ? 1 : 0

  db_proxy_name = aws_db_proxy.main[0].name

  connection_pool_config {
    max_connections_percent      = 100
    max_idle_connections_percent = 50
    session_pinning_filters      = ["EXCLUDE_VARIABLE_SETS"]
  }
}

# RDS Proxy Target
resource "aws_db_proxy_target" "main" {
  count = var.enable_rds_proxy ? 1 : 0

  db_instance_identifier = aws_db_instance.main.identifier
  db_proxy_name          = aws_db_proxy.main[0].name
  target_group_name      = aws_db_proxy_default_target_group.main[0].name
}

# RDS Proxy用IAMロール
resource "aws_iam_role" "rds_proxy" {
  count = var.enable_rds_proxy ? 1 : 0

  name = "${var.project_name}-${var.environment}-rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-rds-proxy-role"
    }
  )
}

resource "aws_iam_role_policy" "rds_proxy" {
  count = var.enable_rds_proxy ? 1 : 0

  name = "${var.project_name}-${var.environment}-rds-proxy-policy"
  role = aws_iam_role.rds_proxy[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.db_credentials.arn
      }
    ]
  })
}
