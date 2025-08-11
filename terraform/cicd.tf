# GitHub OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # GitHub OIDCプロバイダーのサムプリント
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-github-oidc"
  }
}

# GitHub Actions用IAMロール
resource "aws_iam_role" "github_actions" {
  count = var.enable_github_oidc ? 1 : 0

  name = "${var.project_name}-${var.environment}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # GitHubリポジトリを指定
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-github-actions"
  }
}

# GitHub Actions用のIAMポリシー
resource "aws_iam_role_policy" "github_actions" {
  count = var.enable_github_oidc ? 1 : 0

  name = "${var.project_name}-${var.environment}-github-actions-policy"
  role = aws_iam_role.github_actions[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ECR関連の権限
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = [
          aws_ecr_repository.app.arn,
          "${aws_ecr_repository.app.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      # ECS関連の権限
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition"
        ]
        Resource = "*"
      },
      # S3関連の権限（フロントエンド用）
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.frontend.arn,
          "${aws_s3_bucket.frontend.arn}/*"
        ]
      },
      # CloudFront関連の権限
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:ListDistributions",
          "cloudfront:GetDistribution"
        ]
        Resource = "*"
      },
      # IAM PassRole権限（ECSタスク実行用）
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.ecs_execution_role.arn,
          aws_iam_role.ecs_task_role.arn
        ]
      }
    ]
  })
}

# ECRへのプッシュ権限
resource "aws_iam_role_policy" "github_actions_ecr" {
  count = var.enable_github_oidc ? 1 : 0

  name = "${var.project_name}-${var.environment}-github-ecr"
  role = aws_iam_role.github_actions[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = [
          aws_ecr_repository.app.arn,
          "${aws_ecr_repository.app.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

# ECSデプロイ権限
resource "aws_iam_role_policy" "github_actions_ecs" {
  count = var.enable_github_oidc ? 1 : 0

  name = "${var.project_name}-${var.environment}-github-ecs"
  role = aws_iam_role.github_actions[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:ListTaskDefinitions",
          "ecs:DescribeClusters"
        ]
        Resource = [
          aws_ecs_cluster.main.arn,
          aws_ecs_service.app.id,
          "arn:aws:ecs:${var.aws_region}:*:task-definition/${var.project_name}-${var.environment}-app:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.ecs_execution_role.arn,
          aws_iam_role.ecs_task_role.arn
        ]
      }
    ]
  })
}

# S3とCloudFrontデプロイ権限
resource "aws_iam_role_policy" "github_actions_frontend" {
  count = var.enable_github_oidc ? 1 : 0

  name = "${var.project_name}-${var.environment}-github-frontend"
  role = aws_iam_role.github_actions[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.frontend.arn,
          "${aws_s3_bucket.frontend.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = aws_cloudfront_distribution.frontend.arn
      }
    ]
  })
}

# アーティファクト保存用S3バケット
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.project_name}-${var.environment}-artifacts"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-${var.environment}-artifacts"
  }
}

# バケットの暗号化
resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ライフサイクルポリシー
resource "aws_s3_bucket_lifecycle_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    id     = "delete-old-artifacts"
    status = "Enabled"

    filter {}

    expiration {
      days = var.artifact_retention_days
    }
  }
}

# デプロイ設定をParameter Storeに保存
resource "aws_ssm_parameter" "ecr_repository_url" {
  name  = "/${var.project_name}/${var.environment}/ecr-repository-url"
  type  = "String"
  value = aws_ecr_repository.app.repository_url

  tags = {
    Name = "${var.project_name}-${var.environment}-ecr-url"
  }
}

resource "aws_ssm_parameter" "ecs_cluster_name" {
  name  = "/${var.project_name}/${var.environment}/ecs-cluster-name"
  type  = "String"
  value = aws_ecs_cluster.main.name

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-cluster"
  }
}

resource "aws_ssm_parameter" "ecs_service_name" {
  name  = "/${var.project_name}/${var.environment}/ecs-service-name"
  type  = "String"
  value = aws_ecs_service.app.name

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-service"
  }
}
