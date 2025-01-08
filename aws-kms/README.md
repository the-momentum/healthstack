# AWS KMS Module

## AWS KMS

AWS Key Management Service (KMS) is a managed service that makes it easy to create and manage cryptographic keys used to secure your data.
It's fully integrated with AWS services like S3, EBS, and RDS to provide data encryption at rest.


## Usage

```hcl
module "kms" {
  source = "github.com/momentum-ai/healthstack.git//aws-kms/module"

  name        = "patient-data-key"
  description = "KMS key for encrypting patient data"
  key_users   = [
    "arn:aws:iam::123456789012:role/ApplicationRole",
    "arn:aws:iam::123456789012:role/BackupRole"
  ]

  tags = {
    Environment = "production"
    DataType    = "ephi"
  }
}
```

## Security Features

This module implements HIPAA-compliant security controls:
- Automatic key rotation enabled (required for HIPAA)
- 30-day deletion window to prevent accidental deletion
- Strict IAM policies following least privilege principle
- Symmetric key encryption enforced
- Safety checks cannot be bypassed

## Example Use Cases

1. **EBS Volume Encryption**

```terraform
resource "aws_ebs_volume" "phi_data" {
  availability_zone = "us-west-2a"
  size             = 100
  encrypted        = true
  kms_key_id       = module.kms.key_arn
}
```

2. **S3 Bucket Encryption**

```terraform
resource "aws_s3_bucket" "medical_records" {
  bucket = "hipaa-medical-records"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "medical_records" {
  bucket = aws_s3_bucket.medical_records.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = module.kms.key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

```
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
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description of the KMS key | `string` | n/a | yes |
| <a name="input_key_users"></a> [key\_users](#input\_key\_users) | List of ARNs of IAM users/roles that should have usage permissions on the key | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name to be used for the KMS key and alias | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be added to the KMS key | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alias_arn"></a> [alias\_arn](#output\_alias\_arn) | The ARN of the KMS alias |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | The ARN of the KMS key |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | The globally unique identifier for the KMS key |
