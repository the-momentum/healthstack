# AWS S3

This module provides a secure and private S3 bucket for hosting sensitive data, such as Personally Identifiable Information (PII).

You can either encrypt the bucket using AWS Key Management Service (KMS) or opt for AWS's default encryption.

For compliance purposes, this bucket logs all activity. Additionally, it supports data retention policies, transitions between S3 storage tiers, and has versioning enabled to ensure data protection and recovery.

This module provides a solution for a specific problem but can be adapted to suit your needs with further customization.

## Example usage

```tf
module "s3" {
  source                 = "github.com/TheMomentumAI/healthstack.git//aws-s3/module"
  bucket_name            = "test-bucket"
  logs_bucket_name       = "test-logs-bucket"
  kms_encryption_enabled = false
  kms_admin_iam_arn      = "arn:aws:iam::123456789012:user/test_user"

  transitions = [
    {
      days          = 30
      storage_class = "STANDARD_IA"
    },
    {
      days          = 180
      storage_class = "GLACIER"
    }
  ]

  enable_expiration = true
  expiration_days   = 365

  logs_ia_transition_days      = 30
  logs_glacier_transition_days = 180
  logs_expiration_days         = 365
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the S3 bucket | `string` | n/a | yes |
| <a name="input_enable_expiration"></a> [enable\_expiration](#input\_enable\_expiration) | Enable expiration of objects in the S3 bucket | `bool` | `false` | no |
| <a name="input_expiration_days"></a> [expiration\_days](#input\_expiration\_days) | Number of days before expiring the objects | `number` | `null` | no |
| <a name="input_kms_admin_iam_arn"></a> [kms\_admin\_iam\_arn](#input\_kms\_admin\_iam\_arn) | The ARN of the IAM role that can administer the KMS key | `string` | `null` | no |
| <a name="input_kms_encryption_enabled"></a> [kms\_encryption\_enabled](#input\_kms\_encryption\_enabled) | Enable KMS encryption for the S3 bucket | `bool` | `false` | no |
| <a name="input_logs_bucket_name"></a> [logs\_bucket\_name](#input\_logs\_bucket\_name) | The name of the S3 bucket used for logging access to data bucket | `string` | n/a | yes |
| <a name="input_logs_expiration_days"></a> [logs\_expiration\_days](#input\_logs\_expiration\_days) | Number of days before expiring the objects | `number` | n/a | yes |
| <a name="input_logs_glacier_transition_days"></a> [logs\_glacier\_transition\_days](#input\_logs\_glacier\_transition\_days) | Number of days before transitioning S3 access logs to GLACIER storage class | `number` | n/a | yes |
| <a name="input_logs_ia_transition_days"></a> [logs\_ia\_transition\_days](#input\_logs\_ia\_transition\_days) | Number of days before transitioning S3 access logs to STANDARD\_IA storage class | `number` | n/a | yes |
| <a name="input_transitions"></a> [transitions](#input\_transitions) | List of transition rules for the S3 bucket | <pre>list(object({<br/>    days          = number<br/>    storage_class = string<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_arn"></a> [kms\_arn](#output\_kms\_arn) | n/a |
| <a name="output_logs_bucket_arn"></a> [logs\_bucket\_arn](#output\_logs\_bucket\_arn) | n/a |
| <a name="output_s3_arn"></a> [s3\_arn](#output\_s3\_arn) | n/a |
<!-- END_TF_DOCS -->