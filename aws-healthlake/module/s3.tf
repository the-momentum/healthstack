# Bucket used for import/export
resource "aws_s3_bucket" "data" {
  #checkov:skip=CKV2_AWS_62:LOW severity - notifications not required
  #checkov:skip=CKV_AWS_144:LOW severity - cross region replication is not required

  bucket_prefix = var.data_bucket_name
}

resource "aws_s3_bucket_lifecycle_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    filter {}

    id     = "log"
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "data" {
  bucket = aws_s3_bucket.data.id

  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "${aws_s3_bucket.data.bucket}/logs"
}

################################################################################
# Access logs bucket

resource "aws_s3_bucket" "access_logs" {
  #checkov:skip=CKV2_AWS_62:LOW severity - notifications not required
  #checkov:skip=CKV_AWS_144:LOW severity - cross region replication is not required
  #checkov:skip=CKV_AWS_145:MEDIUM severity - encrypted by AWS managed keys

  bucket_prefix = var.logs_bucket_name
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

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
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 365
      storage_class = "GLACIER"
    }

    expiration {
      days = 1825
    }
  }
}

resource "aws_s3_bucket_logging" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "log/"
}


resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}