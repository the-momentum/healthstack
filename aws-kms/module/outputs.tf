
output "key_arn" {
  description = "The ARN of the KMS key"
  value       = aws_kms_key.this.arn
}

output "key_id" {
  description = "The globally unique identifier for the KMS key"
  value       = aws_kms_key.this.key_id
}

output "alias_arn" {
  description = "The ARN of the KMS alias"
  value       = aws_kms_alias.this.arn
}