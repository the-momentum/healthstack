resource "aws_s3_bucket" "logs" {
  #checkov:skip=CKV2_AWS_62:LOW severity - notifications not required
  #checkov:skip=CKV_AWS_144:LOW severity - cross region replication is not required
  #checkov:skip=CKV_AWS_145:MEDIUM severity - encrypted by AWS managed keys

  bucket_prefix = var.logs_bucket_name
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    filter {}

    id     = "failed-uploads"
    status = "Enabled"
  }

  rule {
    filter {
      prefix = "log/"
    }

    id     = "transition"
    status = "Enabled"

    transition {
      days          = var.logs_ia_transition_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.logs_glacier_transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.logs_expiration_days
    }
  }
}

resource "aws_s3_bucket_logging" "logs" {
  bucket = aws_s3_bucket.logs.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "log/"
}


resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}