locals {
  common_tags = {
    Module      = "storage"
    ManagedBy   = "terraform"
    Environment = var.environment
    Project     = var.project_name
  }
}

# フロントエンド用S3バケット
resource "aws_s3_bucket" "frontend" {
  bucket        = "${var.project_name}-${var.environment}-frontend"
  force_destroy = var.environment != "prod"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-frontend"
      Type = "frontend"
    }
  )
}

# フロントエンドバケットのパブリックアクセスをブロック
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# フロントエンドバケットの暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# フロントエンドバケットのバージョニング設定
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# フロントエンドバケットポリシー（CloudFrontディストリビューション作成後に設定）
resource "aws_s3_bucket_policy" "frontend" {
  count = var.cloudfront_distribution_arn != "" ? 1 : 0
  
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
            "AWS:SourceArn" = var.cloudfront_distribution_arn
          }
        }
      }
    ]
  })
}

# ALBアクセスログ用バケット
resource "aws_s3_bucket" "alb_logs" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket        = "${var.project_name}-${var.environment}-alb-logs"
  force_destroy = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-alb-logs"
      Type = "alb-logs"
    }
  )
}

# ALBログバケットのパブリックアクセスをブロック
resource "aws_s3_bucket_public_access_block" "alb_logs" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ALBログバケットポリシー
resource "aws_s3_bucket_policy" "alb_logs" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.alb_account_id}:root"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs[0].arn}/*"
      }
    ]
  })
}

# ALBログバケットのライフサイクルルール
resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = var.alb_logs_retention_days
    }
  }
}

# CloudFrontアクセスログ用バケット
resource "aws_s3_bucket" "cloudfront_logs" {
  count = var.enable_cloudfront_logging ? 1 : 0

  bucket        = "${var.project_name}-${var.environment}-cf-logs"
  force_destroy = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-cf-logs"
      Type = "cloudfront-logs"
    }
  )
}

# CloudFrontログバケットのACL設定
resource "aws_s3_bucket_acl" "cloudfront_logs" {
  count = var.enable_cloudfront_logging ? 1 : 0

  bucket     = aws_s3_bucket.cloudfront_logs[0].id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.cloudfront_logs]
}

# CloudFrontログバケットのオーナーシップ設定
resource "aws_s3_bucket_ownership_controls" "cloudfront_logs" {
  count = var.enable_cloudfront_logging ? 1 : 0

  bucket = aws_s3_bucket.cloudfront_logs[0].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# CloudFrontログバケットのライフサイクルルール
resource "aws_s3_bucket_lifecycle_configuration" "cloudfront_logs" {
  count = var.enable_cloudfront_logging ? 1 : 0

  bucket = aws_s3_bucket.cloudfront_logs[0].id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = var.cloudfront_logs_retention_days
    }
  }
}

# CI/CDアーティファクト用バケット
resource "aws_s3_bucket" "artifacts" {
  count = var.enable_cicd ? 1 : 0

  bucket        = "${var.project_name}-${var.environment}-artifacts"
  force_destroy = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-artifacts"
      Type = "cicd-artifacts"
    }
  )
}

# アーティファクトバケットの暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  count = var.enable_cicd ? 1 : 0

  bucket = aws_s3_bucket.artifacts[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# アーティファクトバケットのライフサイクルルール
resource "aws_s3_bucket_lifecycle_configuration" "artifacts" {
  count = var.enable_cicd ? 1 : 0

  bucket = aws_s3_bucket.artifacts[0].id

  rule {
    id     = "delete-old-artifacts"
    status = "Enabled"

    filter {}

    expiration {
      days = var.artifacts_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

# バックアップ用バケット（本番環境のみ）
resource "aws_s3_bucket" "backup" {
  count = var.enable_backup ? 1 : 0

  bucket        = "${var.project_name}-${var.environment}-backup"
  force_destroy = false

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-backup"
      Type = "backup"
    }
  )
}

# バックアップバケットの暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
  count = var.enable_backup ? 1 : 0

  bucket = aws_s3_bucket.backup[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# バックアップバケットのバージョニング設定
resource "aws_s3_bucket_versioning" "backup" {
  count = var.enable_backup ? 1 : 0

  bucket = aws_s3_bucket.backup[0].id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# バックアップバケットのライフサイクルルール
resource "aws_s3_bucket_lifecycle_configuration" "backup" {
  count = var.enable_backup ? 1 : 0

  bucket = aws_s3_bucket.backup[0].id

  rule {
    id     = "backup-lifecycle"
    status = "Enabled"

    filter {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = var.backup_retention_days
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
