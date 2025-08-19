# WAF関連
output "waf_web_acl_id" {
  description = "WAF WebACL ID"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].id : ""
}

output "waf_web_acl_arn" {
  description = "WAF WebACL ARN"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].arn : ""
}

# GuardDuty関連
output "guardduty_detector_id" {
  description = "GuardDuty Detector ID"
  value       = var.enable_guardduty ? aws_guardduty_detector.main[0].id : ""
}

# Config関連
output "config_recorder_name" {
  description = "Config Recorder Name"
  value       = var.enable_config ? aws_config_configuration_recorder.main[0].name : ""
}

output "config_required_tags_rule_name" {
  description = "Config Required Tags Rule Name"
  value       = var.enable_config ? aws_config_config_rule.required_tags[0].name : ""
}

output "config_s3_bucket_name" {
  description = "Config S3 Bucket Name"
  value       = var.enable_config ? aws_s3_bucket.config[0].id : ""
}

# IAM関連
output "developer_readonly_policy_arn" {
  description = "Developer Read-only Policy ARN"
  value       = aws_iam_policy.developer_readonly.arn
}