# スケジュールベースのスケーリング（営業時間）
resource "aws_appautoscaling_scheduled_action" "scale_up_morning" {
  count = var.enable_scheduled_scaling ? 1 : 0

  name               = "${var.project_name}-${var.environment}-scale-up-morning"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  schedule           = "cron(0 0 * * MON-FRI *)"  # 平日9時（JST）
  timezone          = "Asia/Tokyo"

  scalable_target_action {
    min_capacity = var.business_hours_min_capacity
    max_capacity = var.business_hours_max_capacity
  }
}

resource "aws_appautoscaling_scheduled_action" "scale_down_evening" {
  count = var.enable_scheduled_scaling ? 1 : 0

  name               = "${var.project_name}-${var.environment}-scale-down-evening"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  schedule           = "cron(0 10 * * MON-FRI *)"  # 平日19時（JST）
  timezone          = "Asia/Tokyo"

  scalable_target_action {
    min_capacity = var.off_hours_min_capacity
    max_capacity = var.off_hours_max_capacity
  }
}
