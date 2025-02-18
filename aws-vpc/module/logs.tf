#===============================================================================
# VPC Flow Logs
#===============================================================================

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  count             = try(var.flow_log_config.cw_logs_destination_enabled, false) ? 1 : 0

  name              = "/vpc/${aws_vpc.this.id}"
  log_group_class   = "STANDARD"
  retention_in_days = 365
}

data "aws_iam_policy_document" "flow_logs_publisher_assume_role_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "flow_logs_publisher" {
  count              = try(var.flow_log_config.cw_logs_destination_enabled, false) ? 1 : 0

  name_prefix        = "vpc-flow-logs-role-"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_publisher_assume_role_policy.json
}

data "aws_iam_policy_document" "flow_logs_publish_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "flow_logs_publish_policy" {
  count       = try(var.flow_log_config.cw_logs_destination_enabled, false) ? 1 : 0
  name_prefix = "vpc-flow-logs-policy-"
  role        = aws_iam_role.flow_logs_publisher[0].id
  policy      = data.aws_iam_policy_document.flow_logs_publish_policy.json
}

resource "aws_flow_log" "flow_log_to_cloudwatch" {
  count           = try(var.flow_log_config.cw_logs_destination_enabled, false) ? 1 : 0
  iam_role_arn    = aws_iam_role.flow_logs_publisher[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id
}

#===============================================================================
# VPC Flow Log - S3 Bucket Destination
#===============================================================================

resource "aws_flow_log" "s3" {
  count                = var.flow_log_config.s3_destination_enabled ? 1 : 0
  log_destination      = var.flow_log_config.s3_bucket_arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this.id
}
