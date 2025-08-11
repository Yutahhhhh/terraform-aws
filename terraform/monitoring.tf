# ALBアクセスログ用S3バケット
resource "aws_s3_bucket" "alb_logs" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket        = "${var.project_name}-${var.environment}-alb-logs"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-logs"
  }
}

# バケットのパブリックアクセスブロック
resource "aws_s3_bucket_public_access_block" "alb_logs" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ALBサービスアカウントからのアクセス許可
resource "aws_s3_bucket_policy" "alb_logs" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::582318560864:root"  # 東京リージョンのALBサービスアカウント
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs[0].arn}/*"
      }
    ]
  })
}

# ログのライフサイクル設定
resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }

    transition {
      days          = 7
      storage_class = "GLACIER_IR"
    }
  }
}
