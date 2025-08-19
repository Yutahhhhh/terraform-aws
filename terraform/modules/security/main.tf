locals {
  common_tags = {
    Module      = "security"
    ManagedBy   = "terraform"
    Environment = var.environment
    Project     = var.project_name
  }
}

# データソース
data "aws_caller_identity" "current" {}

#============================================
# WAF (Web Application Firewall)
#============================================

# WAF WebACL
resource "aws_wafv2_web_acl" "main" {
  count = var.enable_waf ? 1 : 0

  name  = "${var.project_name}-${var.environment}-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # AWS Managed Rule - Core Rule Set
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        # 特定のルールを除外する場合
        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use {
            allow {}
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # SQL Injection対策
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # レート制限ルール
  rule {
    name     = "RateLimitRule"
    priority = 3

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.waf_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitMetric"
      sampled_requests_enabled   = true
    }
  }

  # 地理的制限（必要に応じて）
  dynamic "rule" {
    for_each = length(var.allowed_countries) > 0 ? [1] : []
    content {
      name     = "GeoLocationRule"
      priority = 4

      action {
        block {}
      }

      statement {
        not_statement {
          statement {
            geo_match_statement {
              country_codes = var.allowed_countries
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "GeoLocationMetric"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WAFMetric"
    sampled_requests_enabled   = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-waf"
    }
  )
}


#============================================
# GuardDuty
#============================================

# GuardDuty Detector
resource "aws_guardduty_detector" "main" {
  count = var.enable_guardduty ? 1 : 0

  enable                       = true
  finding_publishing_frequency = var.guardduty_finding_frequency

  # S3 Logs Protection
  datasources {
    s3_logs {
      enable = var.enable_s3_protection
    }
    
    # EKS Audit Logs（ECS使用時は不要だが将来の拡張用）
    kubernetes {
      audit_logs {
        enable = false
      }
    }
    
    # Malware Protection
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.enable_malware_protection
        }
      }
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-guardduty"
    }
  )
}

# SNSトピックへの通知設定
resource "aws_cloudwatch_event_rule" "guardduty" {
  count = var.enable_guardduty && var.alarm_sns_topic_arn != "" ? 1 : 0

  name        = "${var.project_name}-${var.environment}-guardduty-findings"
  description = "GuardDuty findings notification"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [
        { numeric = [">=", var.guardduty_severity_threshold] }
      ]
    }
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-guardduty-rule"
    }
  )
}

resource "aws_cloudwatch_event_target" "guardduty_sns" {
  count = var.enable_guardduty && var.alarm_sns_topic_arn != "" ? 1 : 0

  rule      = aws_cloudwatch_event_rule.guardduty[0].name
  target_id = "SendToSNS"
  arn       = var.alarm_sns_topic_arn
}

#============================================
# AWS Config
#============================================

# Config用S3バケット
resource "aws_s3_bucket" "config" {
  count = var.enable_config ? 1 : 0

  bucket        = "${var.project_name}-${var.environment}-config-logs"
  force_destroy = var.environment != "prod"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-config-logs"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "config" {
  count = var.enable_config ? 1 : 0

  bucket = aws_s3_bucket.config[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Config Recorder用IAMロール
resource "aws_iam_role" "config" {
  count = var.enable_config ? 1 : 0

  name = "${var.project_name}-${var.environment}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-config-role"
    }
  )
}

resource "aws_iam_role_policy" "config" {
  count = var.enable_config ? 1 : 0

  name = "${var.project_name}-${var.environment}-config-policy"
  role = aws_iam_role.config[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketAcl",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.config[0].arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.config[0].arn}/*"
        Condition = {
          StringLike = {
            "s3:x-amz-server-side-encryption" = "AES256"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "config:Put*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Delivery Channel
resource "aws_config_delivery_channel" "main" {
  count = var.enable_config ? 1 : 0

  name           = "${var.project_name}-${var.environment}-channel"
  s3_bucket_name = aws_s3_bucket.config[0].bucket

  snapshot_delivery_properties {
    delivery_frequency = "TwentyFour_Hours"
  }
}

# Configuration Recorder
resource "aws_config_configuration_recorder" "main" {
  count = var.enable_config ? 1 : 0

  name     = "${var.project_name}-${var.environment}-recorder"
  role_arn = aws_iam_role.config[0].arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  depends_on = [aws_config_delivery_channel.main]
}

# Configuration Recorderの開始
resource "aws_config_configuration_recorder_status" "main" {
  count = var.enable_config ? 1 : 0

  name       = aws_config_configuration_recorder.main[0].name
  is_enabled = true

  depends_on = [aws_config_configuration_recorder.main]
}

# Configルール - 必須タグの確認
resource "aws_config_config_rule" "required_tags" {
  count = var.enable_config ? 1 : 0

  name = "${var.project_name}-${var.environment}-required-tags"

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }

  input_parameters = jsonencode({
    tag1Key = "Environment"
    tag2Key = "Project"
    tag3Key = "ManagedBy"
  })

  depends_on = [aws_config_configuration_recorder.main]
}

# Configルール - S3バケットの暗号化確認
resource "aws_config_config_rule" "s3_encryption" {
  count = var.enable_config ? 1 : 0

  name = "${var.project_name}-${var.environment}-s3-encryption"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Configルール - RDSの暗号化確認
resource "aws_config_config_rule" "rds_encryption" {
  count = var.enable_config && var.enable_rds ? 1 : 0

  name = "${var.project_name}-${var.environment}-rds-encryption"

  source {
    owner             = "AWS"
    source_identifier = "RDS_STORAGE_ENCRYPTED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

#============================================
# IAMロールとポリシーの最適化
#============================================

# ECSタスクロールの最適化（既存のタスクロールに追加ポリシー）
resource "aws_iam_role_policy" "ecs_task_optimized" {
  count = var.ecs_task_role_id != "" ? 1 : 0

  name = "${var.project_name}-${var.environment}-ecs-task-optimized"
  role = var.ecs_task_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3SpecificBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${var.app_bucket_arn}/*"
        ]
      },
      {
        Sid    = "SecretsManagerSpecificAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}/${var.environment}/*"
        ]
      },
      {
        Sid    = "CloudWatchLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "${var.log_group_arn}:*"
        ]
      },
      {
        Sid    = "XRayAccess"
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ]
        Resource = "*"
      }
    ]
  })
}

# 開発者用IAMポリシー（読み取り専用）
resource "aws_iam_policy" "developer_readonly" {
  name        = "${var.project_name}-${var.environment}-developer-readonly"
  description = "Read-only access for developers"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ecs:Describe*",
          "ecs:List*",
          "s3:List*",
          "s3:GetObject",
          "rds:Describe*",
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "logs:Describe*",
          "logs:Get*",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          "iam:*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-developer-policy"
    }
  )
}
