variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名（dev/stg/prod）"
  type        = string
  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "環境名はdev、stg、prodのいずれかである必要があります。"
  }
}

variable "vpc_cidr" {
  description = "VPCのCIDRブロック"
  type        = string
}

variable "enable_nat_gateway" {
  description = "NAT Gatewayを有効にするか"
  type        = bool
  default     = false
}
