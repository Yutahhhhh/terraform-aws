output "ecs_cluster_id" {
  description = "ECSクラスターID"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_name" {
  description = "ECSクラスター名"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ECSクラスターARN"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_execution_role_arn" {
  description = "ECS実行ロールARN"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ECSタスクロールARN"
  value       = aws_iam_role.ecs_task_role.arn
}

output "ecr_repository_arn" {
  description = "ECRリポジトリARN"
  value       = aws_ecr_repository.app.arn
}

output "ecr_repository_url" {
  description = "ECRリポジトリURL"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_service_name" {
  description = "ECSサービス名"
  value       = aws_ecs_service.app.name
}

output "ecs_service_arn" {
  description = "ECSサービスARN"
  value       = aws_ecs_service.app.id
}

output "ecs_task_role_name" {
  description = "ECSタスクロール名"
  value       = aws_iam_role.ecs_task_role.name
}
