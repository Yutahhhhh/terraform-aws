terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # backend.hclで設定
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# 共通タグの定義
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Network Module
module "network" {
  source = "../../modules/network"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  enable_nat_gateway = var.enable_nat_gateway
}

# Security Module
module "security" {
  source = "../../modules/security"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.network.vpc_id
  vpc_cidr_block       = var.vpc_cidr
  enable_vpc_endpoints = true
}

# Storage Module
module "storage" {
  source = "../../modules/storage"

  project_name                = var.project_name
  environment                 = var.environment
  enable_versioning           = true
  cloudfront_distribution_arn = "" # 後で設定
  enable_alb_access_logs      = var.enable_alb_access_logs
  enable_cloudfront_logging   = true
  enable_cicd                 = var.enable_cicd
  artifacts_retention_days    = 30
  enable_backup               = false
}

# Database Module
module "database" {
  source = "../../modules/database"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  ecs_security_group_id = module.compute.ecs_security_group_id

  db_engine_version           = "15.8"
  db_instance_class           = "db.t3.small"
  db_allocated_storage        = 50
  db_username                 = "postgres"
  multi_az                    = true
  backup_retention_period     = 7
  enable_performance_insights = true
  enable_rds_proxy            = true
}

# Compute Module
module "compute" {
  source = "../../modules/compute"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  task_cpu       = "512"
  task_memory    = "1024"
  desired_count  = 2
  container_port = 3000

  min_capacity = 2
  max_capacity = 4

  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  alb_security_group_id = module.loadbalancer.alb_security_group_id
  target_group_arn      = module.loadbalancer.target_group_arn
  db_secret_arn         = module.database.db_secret_arn

  allowed_origins         = var.allowed_origins
  enable_security_headers = var.enable_security_headers
  enable_xray_tracing     = var.enable_xray_tracing
}

# Load Balancer Module
module "loadbalancer" {
  source = "../../modules/loadbalancer"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  target_port         = 3000
  health_check_path   = "/health"
  enable_https        = var.alb_certificate_arn != ""
  certificate_arn     = var.alb_certificate_arn
  enable_access_logs  = var.enable_alb_access_logs
  access_logs_bucket  = var.enable_alb_access_logs ? module.storage.alb_logs_bucket_name : null
  enable_xray_tracing = var.enable_xray_tracing
}

# CDN Module
module "cdn" {
  source = "../../modules/cdn"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags

  cloudfront_price_class    = "PriceClass_100"
  frontend_domain_name      = var.frontend_domain_name
  frontend_certificate_arn  = var.frontend_certificate_arn
  enable_cloudfront_logging = true

  s3_bucket_id                       = module.storage.frontend_bucket_id
  s3_bucket_domain_name              = module.storage.frontend_bucket_regional_domain_name
  alb_dns_name                       = module.loadbalancer.alb_dns_name
  alb_name                           = module.loadbalancer.alb_name
  cloudfront_logs_bucket_domain_name = module.storage.cloudfront_logs_bucket_domain_name
}

# Monitoring Module
module "monitoring" {
  source = "../../modules/monitoring"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  common_tags  = local.common_tags

  ecs_log_group_name = "/ecs/${var.project_name}-${var.environment}"

  alarm_email                  = var.alarm_email
  enable_cpu_alarm             = var.enable_cpu_alarm
  enable_memory_alarm          = var.enable_memory_alarm
  enable_unhealthy_host_alarm  = var.enable_unhealthy_host_alarm
  cpu_utilization_threshold    = var.cpu_utilization_threshold
  memory_utilization_threshold = var.memory_utilization_threshold

  ecs_cluster_name   = module.compute.ecs_cluster_name
  ecs_service_name   = module.compute.ecs_service_name
  ecs_task_role_name = module.compute.ecs_task_role_name

  target_group_arn_suffix  = module.loadbalancer.target_group_arn_suffix
  load_balancer_arn_suffix = module.loadbalancer.alb_arn_suffix

  enable_xray_tracing    = var.enable_xray_tracing
  enable_alb_access_logs = var.enable_alb_access_logs
}

# CI/CD Module
module "cicd" {
  source = "../../modules/cicd"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  common_tags  = local.common_tags

  enable_github_oidc = var.github_repository != ""
  github_repository  = var.github_repository

  ecr_repository_arn = module.compute.ecr_repository_arn
  ecr_repository_url = module.compute.ecr_repository_url

  ecs_cluster_arn        = module.compute.ecs_cluster_arn
  ecs_cluster_name       = module.compute.ecs_cluster_name
  ecs_service_arn        = module.compute.ecs_service_arn
  ecs_service_name       = module.compute.ecs_service_name
  ecs_execution_role_arn = module.compute.ecs_execution_role_arn
  ecs_task_role_arn      = module.compute.ecs_task_role_arn

  frontend_bucket_arn         = module.storage.frontend_bucket_arn
  cloudfront_distribution_arn = module.cdn.cloudfront_distribution_arn

  artifacts_bucket_name = module.storage.artifacts_bucket_name
  artifacts_bucket_arn  = module.storage.artifacts_bucket_arn

  artifact_retention_days = 30
}

# VPC Endpoints Module
module "vpc_endpoints" {
  source = "../../modules/vpc_endpoints"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  common_tags  = local.common_tags

  vpc_id             = module.network.vpc_id
  vpc_cidr           = var.vpc_cidr
  private_subnet_ids = module.network.private_subnet_ids
  route_table_ids = concat(
    module.network.private_route_table_ids,
    [module.network.public_route_table_id]
  )

  enable_vpc_endpoints     = true
  enable_xray_tracing      = var.enable_xray_tracing
  enable_vpc_flow_logs     = true
  flow_logs_retention_days = 30
}

# Data sources
data "aws_caller_identity" "current" {}
