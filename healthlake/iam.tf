resource "aws_iam_role" "healthlake" {
  name = var.healthlake_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "HealthLakeAssumeRole1"
        Effect = "Allow"
        Principal = {
          Service = "healthlake.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "${data.aws_caller_identity.current.account_id}"
          }
          ArnEquals = {
            "aws:SourceArn" = "${awscc_healthlake_fhir_datastore.this.datastore_arn}"
          }
        }
      },
      {
        Sid    = "HealthLakeAssumeRole2"
        Effect = "Allow"
        Principal = {
          Service = "healthlake.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "${data.aws_caller_identity.current.account_id}"
          }
          ArnEquals = {
            "aws:SourceArn" = "${awscc_healthlake_fhir_datastore.this.datastore_arn}"
          }
        }
      }
    ]
    }
  )
}

resource "aws_iam_policy" "healthlake" {
  name        = var.healthlake_policy_name
  description = "Policy for AWS HealthLake to access S3 and KMS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "S3AccessPermissions"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetEncryptionConfiguration",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.data.arn}",
          "${aws_s3_bucket.data.arn}/*"
        ]
      },
      {
        Sid    = "KMSPermissions"
        Effect = "Allow"
        Action = [
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
        ]
        Resource = [
          "${aws_kms_key.s3.arn}"
        ]
      },
    ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.healthlake.name
  policy_arn = aws_iam_policy.healthlake.arn
}


resource "aws_s3_bucket_policy" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ServerAccessLogsPolicy"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.access_logs.arn}/*"
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "${aws_s3_bucket.data.arn}"
          }
          StringEquals = {
            "aws:SourceAccount" = "${data.aws_caller_identity.current.account_id}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "healthlake_service_role" {
  name        = "healthlake-service-role"
  description = "Service role for AWS HealthLake FHIR operations"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "healthlake.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "healthlake_policy" {
  role       = aws_iam_role.healthlake_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonHealthLakeFullAccess"
}