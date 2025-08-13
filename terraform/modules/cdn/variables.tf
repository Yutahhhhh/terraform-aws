variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名 (dev, stg, prod)"
  type        = string
}

variable "common_tags" {
  description = "共通タグ"
  type        = map(string)
  default     = {}
}

# CloudFront関連
variable "cloudfront_price_class" {
  description = "CloudFrontの価格クラス"
  type        = string
  default     = "PriceClass_All"
}

variable "frontend_domain_name" {
  description = "フロントエンドのカスタムドメイン名"
  type        = string
  default     = ""
}

variable "frontend_certificate_arn" {
  description = "フロントエンド用SSL証明書のARN"
  type        = string
  default     = ""
}

variable "enable_cloudfront_logging" {
  description = "CloudFrontログを有効にするか"
  type        = bool
  default     = false
}

# S3関連
variable "s3_bucket_id" {
  description = "フロントエンド用S3バケットID"
  type        = string
}

variable "s3_bucket_domain_name" {
  description = "フロントエンド用S3バケットのドメイン名"
  type        = string
}

# ALB関連
variable "alb_dns_name" {
  description = "ALBのDNS名"
  type        = string
}

variable "alb_name" {
  description = "ALB名"
  type        = string
}

# ログ関連
variable "cloudfront_logs_bucket_domain_name" {
  description = "CloudFrontログ用S3バケットのドメイン名"
  type        = string
  default     = ""
}
