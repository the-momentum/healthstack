resource "aws_s3_bucket" "this" {
  #checkov:skip=CKV2_AWS_62:LOW severity - notifications not required
  #checkov:skip=CKV_AWS_144:LOW severity - cross region replication is not required

  bucket = var.bucket_name
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    filter {}

    dynamic "transition" {
      for_each = var.transitions
      content {
        days          = transition.value.days
        storage_class = transition.value.storage_class
      }
    }

    dynamic "expiration" {
      for_each = var.enable_expiration ? [1] : []
      content {
        days = var.expiration_days
      }
    }

    id     = "transition"
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_encryption_enabled ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_encryption_enabled ? aws_kms_key.this[0].arn : null
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "this" {
  bucket = aws_s3_bucket.this.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "${aws_s3_bucket.this.bucket}/logs"
}