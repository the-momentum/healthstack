output "cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.this.arn
}

output "task_role_arn" {
  description = "The ARN of the IAM role used by the ECS tasks"
  value       = aws_iam_role.task.arn
}

output "execution_role_arn" {
  description = "The ARN of the IAM role used for ECS task execution"
  value       = aws_iam_role.execution.arn
}

output "task_definitions" {
  description = "Map of task definition ARNs by service name"
  value       = { for k, v in aws_ecs_task_definition.service : k => v.arn }
}

output "service_ids" {
  description = "Map of service IDs by service name"
  value       = { for k, v in aws_ecs_service.service : k => v.id }
}

output "cloudwatch_log_groups" {
  description = "Map of CloudWatch Log Group ARNs by service name"
  value       = { for k, v in aws_cloudwatch_log_group.service : k => v.arn }
}