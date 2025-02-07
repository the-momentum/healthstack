# AWS CloudTrail Monitoring Module

This module creates a AWS CloudTrail setup with enhanced monitoring and security alerts.
It includes CloudWatch Logs integration, KMS encryption, S3 bucket configuration, and automated security alerting through SNS.

## Implementated Features

- CloudTrail logs are encrypted using KMS and stored in a dedicated S3 bucket
- CloudTrail logs are stored in an S3 bucket with versioning enabled for data protection and audit history
- Variable retention period depending on requirements
- After 60 days, logs are automatically transitioned to Glacier storage for cost optimization
- CloudWatch Logs and SNS are used for monitoring and alerting

## Security Event Monitoring and Alerting

The module monitors several critical security events:
- IAM policy and user changes
- Failed login attempts
- Root account usage
- Security group modifications
- Failed backup jobs
- Network configuration changes (VPC, NACL)

## Example Usage

```hcl
module "cloudtrail" {
  source = "github.com/the-momentum/healthstack.git//aws-cloudtrail/module"

  name = "audit"

  # optional - if not provided, a new KMS key will be created
  kms_key_arn = "arn:aws:kms:region:account:key/1234abcd-12ab-34cd-56ef-1234567890ab"

  alert_emails = [
    "security@example.com",
    "admin@example.com"
  ]

  tags = {
    Environment = "production"
    Purpose     = "security-audit"
  }
}
```

## Logs lookup

Logs can be viewed in the CloudWatch Logs console or queried with CLI.

### AWS Console

In console, navigate to CloudTrail and select Event History. Then apply filters like:
- Event name + DeleteDBSecurityGroup
- Event source + rds.amazonaws.com
- Resource type + AWS::S3::Bucket
- User agent + IAM user or role name

### CLI

Here are some useful queries:

```bash
# Get all events from RDS from specific time range
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=rds.amazonaws.com \
  --query 'Events[?EventName == `CreateDBInstance` ||
                  EventName == `DeleteDBInstance` ||
                  EventName == `ModifyDBInstance` ||
                  EventName == `RebootDBInstance` ||
                  EventName == `RestoreDBInstanceFromDBSnapshot` ||
                  EventName == `StartDBInstance` ||
                  EventName == `StopDBInstance`]' \
  --start-time 2024-01-01 \
  --end-time 2025-02-07

# Get all events from RDS from specific time range and format as JSON
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=rds.amazonaws.com \
  --start-time 2024-01-01 \
  --end-time 2025-02-07 | \
  jq '.Events[] | {
    EventName: .EventName,
    EventTime: .EventTime,
    Username: .Username,
    IP: .CloudTrailEvent | fromjson | .sourceIPAddress,
    UserAgent: .CloudTrailEvent | fromjson | .userAgent
  }'

# Filter for events related to a specific RDS instance
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=ResourceName,AttributeValue=database-1 \
  --start-time 2025-01-01 \
  --end-time 2025-02-07

# Get all events from S3 and RDS in the last 24 hours
aws cloudtrail lookup-events \
  --start-time $(date -v-24H -u "+%Y-%m-%dT%H:%M:%SZ") \
  --query 'Events[?EventSource==`s3.amazonaws.com` || EventSource==`rds.amazonaws.com`]' | \
  jq '.[] | select(.EventName | contains("Get") or contains("Put") or contains("Delete")) | {
    EventTime: .EventTime,
    Service: .EventSource,
    Action: .EventName,
    User: .Username,
    IP: (.CloudTrailEvent | fromjson).sourceIPAddress
  }'


```

Cross-Platform Note:
- for Linux systems, use `-d '24 hours ago'` syntax
- for macOS systems, use `-v-24H` syntax
- alternatively, use explicit `--start-time` and `--end-time` which works on both systems


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_metric_filter.failed_login_action](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_log_metric_filter.iam_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_log_metric_filter.network_changes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_log_metric_filter.root_login](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_log_metric_filter.security_group_changes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.failed_login_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.iam_changes_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.network_changes_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.root_login_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.security_group_changes_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_role.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_sns_topic.alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.alerts_email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_emails"></a> [alert\_emails](#input\_alert\_emails) | List of email addresses for security alerts | `list(string)` | `[]` | no |
| <a name="input_alert_threshold"></a> [alert\_threshold](#input\_alert\_threshold) | Threshold for general security alerts | `number` | `1` | no |
| <a name="input_database_access_threshold"></a> [database\_access\_threshold](#input\_database\_access\_threshold) | Threshold for database access alerts | `number` | `100` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Existing KMS key ARN for encryption. If not provided, a new key will be created | `string` | `null` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain CloudWatch logs | `number` | `180` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for all resources | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudtrail_arn"></a> [cloudtrail\_arn](#output\_cloudtrail\_arn) | ARN of the CloudTrail |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN of the KMS key used for encryption |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name of the CloudWatch Log Group |
