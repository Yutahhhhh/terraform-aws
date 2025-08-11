# フロントエンド用S3バケット
resource "aws_s3_bucket" "frontend" {
  bucket        = "${var.project_name}-${var.environment}-frontend"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-${var.environment}-frontend"
  }
}

# バケットのパブリックアクセスをブロック
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# バケットの暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# バケットのバージョニング設定
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# CloudFrontアクセスログ用バケット（オプション）
resource "aws_s3_bucket" "cloudfront_logs" {
  count = var.enable_cloudfront_logging ? 1 : 0

  bucket        = "${var.project_name}-${var.environment}-cf-logs"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-${var.environment}-cf-logs"
  }
}

# Logバケットのライフサイクルルール
resource "aws_s3_bucket_lifecycle_configuration" "cloudfront_logs" {
  count = var.enable_cloudfront_logging ? 1 : 0

  bucket = aws_s3_bucket.cloudfront_logs[0].id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }
  }
}

# S3バケットポリシー
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.frontend.arn
          }
        }
      }
    ]
  })
}
