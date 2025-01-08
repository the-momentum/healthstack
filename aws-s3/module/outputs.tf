output "s3_arn" {
  value = aws_s3_bucket.this.arn
}

output "kms_arn" {
  value = var.kms_encryption_enabled ? aws_kms_key.this[0].arn : null
}

output "logs_bucket_arn" {
  value = aws_s3_bucket.logs.arn
}
