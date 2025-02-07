output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = aws_cloudtrail.this.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.this.name
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = local.kms_key_arn
}