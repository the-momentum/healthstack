#===============================================================================
# KMS Key for CloudWatch Logs Encryption (if not provided)
# Provides default encryption for flow logs
#===============================================================================
resource "aws_kms_key" "cloudwatch_logs" {
  count = try(var.flow_log_config.cw_logs_destination_enabled, false) && var.flow_log_config.cw_logs_kms_key_arn == null && var.flow_log_config.create_kms_key ? 1 : 0

  description             = "KMS key for encrypting CloudWatch Logs for VPC ${var.vpc_name}"
  deletion_window_in_days = var.flow_log_config.kms_key_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.cloudwatch_logs_kms[0].json
}

resource "aws_kms_alias" "cloudwatch_logs" {
  count = try(var.flow_log_config.cw_logs_destination_enabled, false) && var.flow_log_config.cw_logs_kms_key_arn == null && var.flow_log_config.create_kms_key ? 1 : 0

  name          = "alias/vpc-flow-logs-${var.vpc_name}"
  target_key_id = aws_kms_key.cloudwatch_logs[0].key_id
}

# KMS key policy that allows CloudWatch Logs service to use the key
data "aws_iam_policy_document" "cloudwatch_logs_kms" {
  count = try(var.flow_log_config.cw_logs_destination_enabled, false) && var.flow_log_config.cw_logs_kms_key_arn == null && var.flow_log_config.create_kms_key ? 1 : 0

  # Default policy that allows the account to manage the key
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  # Allow CloudWatch Logs to use the key
  statement {
    sid    = "Allow CloudWatch Logs to use the key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

# Get the current AWS account ID for use in policies
data "aws_caller_identity" "current" {}