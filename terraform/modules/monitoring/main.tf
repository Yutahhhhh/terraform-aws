# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", { stat = "Average" }],
            [".", "MemoryUtilization", { stat = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ECS Resource Utilization"
          period  = 300
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average" }],
            [".", "RequestCount", { stat = "Sum", yAxis = "right" }]
          ]
          view   = "timeSeries"
          region = var.aws_region
          title  = "ALB Performance"
          period = 300
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", { stat = "Sum" }],
            [".", "HTTPCode_Target_4XX_Count", { stat = "Sum" }],
            [".", "HTTPCode_Target_5XX_Count", { stat = "Sum" }]
          ]
          view   = "timeSeries"
          region = var.aws_region
          title  = "HTTP Response Codes"
          period = 300
        }
      },
      {
        type = "log"
        properties = {
          query   = "SOURCE '${var.ecs_log_group_name}' | fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 20"
          region  = var.aws_region
          title   = "Recent Errors"
        }
      }
    ]
  })
}

# SNS Topic（アラーム通知先）
resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-${var.environment}-alarms"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-alarms"
  })
}

# メール通知設定
resource "aws_sns_topic_subscription" "alarm_email" {
  count = var.alarm_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# CPU使用率アラーム
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  count = var.enable_cpu_alarm ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_utilization_threshold
  alarm_description   = "This metric monitors ECS CPU utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-cpu-alarm"
  })
}

# メモリ使用率アラーム
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  count = var.enable_memory_alarm ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-ecs-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.memory_utilization_threshold
  alarm_description   = "This metric monitors ECS memory utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-memory-alarm"
  })
}

# Target Group異常ホストアラーム
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  count = var.enable_unhealthy_host_alarm ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-alb-unhealthy"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_description   = "Alert when unhealthy targets detected"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    TargetGroup  = var.target_group_arn_suffix
    LoadBalancer = var.load_balancer_arn_suffix
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-unhealthy-alarm"
  })
}

# X-Rayサービスマップ用のサンプリングルール
resource "aws_xray_sampling_rule" "main" {
  count = var.enable_xray_tracing ? 1 : 0

  rule_name      = "${var.project_name}-${var.environment}-sampling"
  priority       = 1000
  version        = 1
  reservoir_size = 1
  fixed_rate     = 0.05  # 5%のリクエストをサンプリング
  url_path       = "*"
  host           = "*"
  http_method    = "*"
  service_type   = "*"
  service_name   = "*"
  resource_arn   = "*"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-sampling-rule"
  })
}

# ECS Task RoleにX-Ray権限を追加
resource "aws_iam_role_policy" "ecs_xray_policy" {
  count = var.enable_xray_tracing ? 1 : 0

  name = "${var.project_name}-${var.environment}-ecs-xray-policy"
  role = var.ecs_task_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets",
          "xray:GetSamplingStatisticSummaries"
        ]
        Resource = "*"
      }
    ]
  })
}
