# Local Valuesで共通設定を定義
locals {
  common_tags = {
    Module      = "loadbalancer"
    ManagedBy   = "terraform"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  # HTTP inbound
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS inbound
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-alb-sg"
    }
  )
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  # ALB設定
  enable_cross_zone_load_balancing = true
  enable_http2                     = true
  enable_waf_fail_open            = false

  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = "alb"
      enabled = true
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-alb"
    }
  )
}

# Target Group for ECS Fargate
resource "aws_lb_target_group" "ecs" {
  name        = "${var.project_name}-${var.environment}-ecs-tg"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  # ヘルスチェック設定
  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  # ECSサービスが削除される前にターゲットの登録解除を待つ
  deregistration_delay = var.deregistration_delay

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-tg"
    }
  )
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  # HTTPSが有効な場合はHTTPSにリダイレクト
  dynamic "default_action" {
    for_each = var.enable_https ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  # HTTPSが無効な場合は404を返す
  dynamic "default_action" {
    for_each = var.enable_https ? [] : [1]
    content {
      type = "fixed-response"
      fixed_response {
        content_type = "text/plain"
        message_body = "Not Found"
        status_code  = "404"
      }
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-http-listener"
    }
  )
}

# HTTPS Listener（証明書が提供された場合のみ）
resource "aws_lb_listener" "https" {
  count = var.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-https-listener"
    }
  )
}

# APIエンドポイント用のListener Rule（HTTP）
resource "aws_lb_listener_rule" "api_http" {
  count = var.enable_https ? 0 : 1

  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }

  condition {
    path_pattern {
      values = var.api_path_patterns
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-api-rule-http"
    }
  )
}

# APIエンドポイント用のListener Rule（HTTPS）
resource "aws_lb_listener_rule" "api_https" {
  count = var.enable_https ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }

  condition {
    path_pattern {
      values = var.api_path_patterns
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-api-rule-https"
    }
  )
}

# CORS Preflight用のListener Rule（HTTP）
resource "aws_lb_listener_rule" "cors_preflight_http" {
  count = var.enable_cors && !var.enable_https ? 1 : 0

  listener_arn = aws_lb_listener.http.arn
  priority     = 99

  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = ""
      status_code  = "200"
    }
  }

  condition {
    http_request_method {
      values = ["OPTIONS"]
    }
  }

  condition {
    path_pattern {
      values = var.api_path_patterns
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-cors-preflight-http"
    }
  )
}

# CORS Preflight用のListener Rule（HTTPS）
resource "aws_lb_listener_rule" "cors_preflight_https" {
  count = var.enable_cors && var.enable_https ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
  priority     = 99

  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = ""
      status_code  = "200"
    }
  }

  condition {
    http_request_method {
      values = ["OPTIONS"]
    }
  }

  condition {
    path_pattern {
      values = var.api_path_patterns
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-cors-preflight-https"
    }
  )
}
