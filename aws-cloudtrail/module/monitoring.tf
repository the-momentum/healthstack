################################################################################
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/cloudtrail/${var.name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = local.kms_key_arn
  tags              = var.tags

  depends_on = [aws_kms_key.this]
}

# IAM Actions #
resource "aws_cloudwatch_log_metric_filter" "iam_actions" {
  name           = "IAMActions"
  log_group_name = aws_cloudwatch_log_group.this.name

  pattern = <<EOF
{
  ($.eventName = DeleteAccessKey) ||
  ($.eventName = DeleteGroup) ||
  ($.eventName = DeleteGroupPolicy) ||
  ($.eventName = DeleteRole) ||
  ($.eventName = CreateGroup) ||
  ($.eventName = DeleteRolePolicy) ||
  ($.eventName = DeleteUser) ||
  ($.eventName = DeleteUserPolicy) ||
  ($.eventName = PutGroupPolicy) ||
  ($.eventName = PutRolePolicy) ||
  ($.eventName = PutUserPolicy) ||
  ($.eventName = CreatePolicy) ||
  ($.eventName = DeletePolicy) ||
  ($.eventName = CreatePolicyVersion) ||
  ($.eventName = DeletePolicyVersion) ||
  ($.eventName = AttachRolePolicy) ||
  ($.eventName = DetachRolePolicy) ||
  ($.eventName = AttachUserPolicy) ||
  ($.eventName = DetachUserPolicy) ||
  ($.eventName = AttachGroupPolicy) ||
  ($.eventName = DetachGroupPolicy) ||
  ($.eventName = CreateUser) ||
  ($.eventName = UpdateUser) ||
  ($.eventName = CreateAccessKey) ||
  ($.eventName = CreateLoginProfile)
}
EOF

  metric_transformation {
    name      = "IAMPolicyChanges"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

# Failed Login Events #
resource "aws_cloudwatch_log_metric_filter" "failed_login_action" {
  name           = "LoginEventsFailure"
  log_group_name = aws_cloudwatch_log_group.this.name

  pattern = "{ ($.eventName = \"CredentialVerification\") && ($.serviceEventDetails.CredentialVerification = \"Failure\") }"

  metric_transformation {
    name      = "FailedLogins"
    namespace = "LoginMetrics"
    value     = "1"
  }
}

# Root Account Usage Monitoring #
resource "aws_cloudwatch_log_metric_filter" "root_login" {
  name           = "root-access"
  pattern        = "{ $.userIdentity.type = Root }"
  log_group_name = aws_cloudwatch_log_group.this.name

  metric_transformation {
    name      = "RootAccessCount"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

# Security Group Changes #
resource "aws_cloudwatch_log_metric_filter" "security_group_changes" {
  name    = "security-group-changes"
  pattern = <<EOF
{
  $.eventName = AuthorizeSecurityGroupIngress ||
  $.eventName = AuthorizeSecurityGroupEgress ||
  $.eventName = RevokeSecurityGroupIngress ||
  $.eventName = RevokeSecurityGroupEgress ||
  $.eventName = CreateSecurityGroup ||
  $.eventName = DeleteSecurityGroup ||
  $.eventName = ModifySecurityGroupRules
}
EOF

  log_group_name = aws_cloudwatch_log_group.this.name

  metric_transformation {
    name      = "SecurityGroupChanges"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

# Network Configuration Changes #
resource "aws_cloudwatch_log_metric_filter" "network_changes" {
  name           = "network-changes"
  pattern        = "{ $.eventName = CreateVpc || $.eventName = DeleteVpc || $.eventName = ModifyVpcAttribute || $.eventName = CreateNetworkAcl* || $.eventName = DeleteNetworkAcl* }"
  log_group_name = aws_cloudwatch_log_group.this.name

  metric_transformation {
    name      = "NetworkChanges"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

# ################################################################################
# SNS Topic for Alerts
# ################################################################################

resource "aws_sns_topic" "alerts" {
  name              = "cloudtrail-${var.name}-alerts"
  kms_master_key_id = local.kms_key_arn
  tags              = var.tags
}

resource "aws_sns_topic_subscription" "alerts_email" {
  for_each = toset(var.alert_emails)

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = each.value
}

################################################################################
# CloudWatch Alarms
################################################################################

# IAM Actions #
resource "aws_cloudwatch_metric_alarm" "iam_changes_alarm" {
  alarm_name          = "${var.name}-iam-changes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "IAMPolicyChanges"
  namespace           = "CloudTrailMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "IAM policy changes detected"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  tags                = var.tags
}

# Failed Login Events #
resource "aws_cloudwatch_metric_alarm" "failed_login_alarm" {
  alarm_name          = "${var.name}-failed-logins"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FailedLogins"
  namespace           = "LoginMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "3" # Adjust based on your security requirements
  alarm_description   = "Multiple failed login attempts detected"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  tags                = var.tags
}

# Root Account Usage Monitoring #
resource "aws_cloudwatch_metric_alarm" "root_login_alarm" {
  alarm_name          = "${var.name}-root-access"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RootAccessCount"
  namespace           = "CloudTrailMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Root account usage detected"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  tags                = var.tags
}

# Security Group Changes #
resource "aws_cloudwatch_metric_alarm" "security_group_changes_alarm" {
  alarm_name          = "${var.name}-security-group-changes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "SecurityGroupChanges"
  namespace           = "CloudTrailMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Security group changes detected"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  tags                = var.tags
}

# Network Configuration Changes #
resource "aws_cloudwatch_metric_alarm" "network_changes_alarm" {
  alarm_name          = "${var.name}-network-changes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "NetworkChanges"
  namespace           = "CloudTrailMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Network configuration changes detected"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  tags                = var.tags
}