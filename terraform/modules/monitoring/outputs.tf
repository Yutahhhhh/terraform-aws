output "dashboard_url" {
  description = "CloudWatch Dashboard URL"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "sns_topic_arn" {
  description = "SNSトピックのARN"
  value       = aws_sns_topic.alarms.arn
}


output "xray_sampling_rule_name" {
  description = "X-Rayサンプリングルール名"
  value       = var.enable_xray_tracing ? aws_xray_sampling_rule.main[0].rule_name : null
}
