# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
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

  # 削除時の復旧期間を0日に設定（即座に削除）
  # これはハンズオンで毎回destroyするため
  recovery_window_in_days = 0

  tags = {
    Name = "${var.project_name}-${var.environment}-db-credentials"
  }
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
    value = "all"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-pg15"
  }
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
  multi_az = var.enable_db_multi_az

  # バックアップ設定
  backup_retention_period = 7
  backup_window          = "03:00-04:00"  # UTC
  maintenance_window     = "sun:04:00-sun:05:00"  # UTC

  # パラメータグループ
  parameter_group_name = aws_db_parameter_group.main.name

  # その他の設定
  skip_final_snapshot       = true  # 開発環境では削除時のスナップショットをスキップ
  deletion_protection       = false # 開発環境では削除保護を無効化
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Name = "${var.project_name}-${var.environment}-db"
  }
}