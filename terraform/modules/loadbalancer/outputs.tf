output "alb_id" {
  description = "ALB ID"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "ALB DNS名"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB Zone ID"
  value       = aws_lb.main.zone_id
}

output "target_group_id" {
  description = "ターゲットグループID"
  value       = aws_lb_target_group.ecs.id
}

output "target_group_arn" {
  description = "ターゲットグループARN"
  value       = aws_lb_target_group.ecs.arn
}

output "target_group_name" {
  description = "ターゲットグループ名"
  value       = aws_lb_target_group.ecs.name
}

output "http_listener_arn" {
  description = "HTTPリスナーARN"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "HTTPSリスナーARN"
  value       = var.enable_https ? aws_lb_listener.https[0].arn : null
}

output "api_rule_http_arn" {
  description = "APIルール（HTTP）ARN"
  value       = var.enable_https ? null : aws_lb_listener_rule.api_http[0].arn
}

output "api_rule_https_arn" {
  description = "APIルール（HTTPS）ARN"
  value       = var.enable_https ? aws_lb_listener_rule.api_https[0].arn : null
}

output "cors_rule_http_arn" {
  description = "CORSルール（HTTP）ARN"
  value       = var.enable_cors && !var.enable_https ? aws_lb_listener_rule.cors_preflight_http[0].arn : null
}

output "cors_rule_https_arn" {
  description = "CORSルール（HTTPS）ARN"
  value       = var.enable_cors && var.enable_https ? aws_lb_listener_rule.cors_preflight_https[0].arn : null
}

output "alb_endpoint" {
  description = "ALBエンドポイントURL"
  value       = var.enable_https ? "https://${aws_lb.main.dns_name}" : "http://${aws_lb.main.dns_name}"
}

output "alb_name" {
  description = "ALB名"
  value       = aws_lb.main.name
}

output "target_group_arn_suffix" {
  description = "ターゲットグループARNサフィックス"
  value       = aws_lb_target_group.ecs.arn_suffix
}

output "alb_arn_suffix" {
  description = "ALB ARNサフィックス"
  value       = aws_lb.main.arn_suffix
}

output "alb_security_group_id" {
  description = "ALBセキュリティグループID"
  value       = aws_security_group.alb.id
}
