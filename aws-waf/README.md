# AWS WAF

This module introduce AWS Web Application Firewall.

Features:
- IP blacklist whitelist
- enabling AWS managed rules
- rate limiting
- custom HTML response
- logging with KMS encryption

Example usage:

```terraform
module "waf" {
  source = "./modules/waf"

  waf_enabled                = true
  allow_ips_rule_enabled     = false
  bot_control_rule_enabled   = false
  ip_reputation_rule_enabled = false

  target_arn            = "arn:aws:elasticloadbalancing:..."
  ip_addresses_to_allow = [""]
  ip_addresses_to_block = [""]

  kms_admin_iam_arn = "arn:aws:iam::..."

  custom_response_body = {
    key     = "Forbidden"
    content = file("${path.module}/html/403.html")
    response_header = {
      key   = "Host"
      value = "example.com"
    }
    content_type = "TEXT_HTML"
    code         = 403
  }
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
| [aws_cloudwatch_log_group.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_wafv2_ip_set.allow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_ip_set.block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [aws_wafv2_web_acl_logging_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_ips_rule_enabled"></a> [allow\_ips\_rule\_enabled](#input\_allow\_ips\_rule\_enabled) | Variable to enable or disable the allow-ips rule | `bool` | `false` | no |
| <a name="input_anonymous_ip_rule_enabled"></a> [anonymous\_ip\_rule\_enabled](#input\_anonymous\_ip\_rule\_enabled) | Variable to enable or disable the anonymous IP rule | `bool` | `false` | no |
| <a name="input_block_ips_rule_enabled"></a> [block\_ips\_rule\_enabled](#input\_block\_ips\_rule\_enabled) | Variable to enable or disable the block-ips rule | `bool` | `false` | no |
| <a name="input_bot_control_rule_enabled"></a> [bot\_control\_rule\_enabled](#input\_bot\_control\_rule\_enabled) | Variable to enable or disable the bot control rule | `bool` | `false` | no |
| <a name="input_custom_response_body"></a> [custom\_response\_body](#input\_custom\_response\_body) | n/a | <pre>object({<br/>    key     = string<br/>    content = string<br/>    response_header = object({<br/>      key   = string<br/>      value = string<br/>    })<br/>    content_type = string<br/>    code         = number<br/>  })</pre> | n/a | yes |
| <a name="input_ip_addresses_to_allow"></a> [ip\_addresses\_to\_allow](#input\_ip\_addresses\_to\_allow) | n/a | `list(string)` | `[]` | no |
| <a name="input_ip_addresses_to_block"></a> [ip\_addresses\_to\_block](#input\_ip\_addresses\_to\_block) | n/a | `list(string)` | `[]` | no |
| <a name="input_ip_reputation_rule_enabled"></a> [ip\_reputation\_rule\_enabled](#input\_ip\_reputation\_rule\_enabled) | Variable to enable or disable the IP reputation rule | `bool` | `false` | no |
| <a name="input_kms_admin_iam_arn"></a> [kms\_admin\_iam\_arn](#input\_kms\_admin\_iam\_arn) | n/a | `string` | `""` | no |
| <a name="input_known_bad_inputs_rule_enabled"></a> [known\_bad\_inputs\_rule\_enabled](#input\_known\_bad\_inputs\_rule\_enabled) | Variable to enable or disable the known bad inputs rule | `bool` | `false` | no |
| <a name="input_rate_limit"></a> [rate\_limit](#input\_rate\_limit) | n/a | `number` | `500` | no |
| <a name="input_rate_limit_rule_enabled"></a> [rate\_limit\_rule\_enabled](#input\_rate\_limit\_rule\_enabled) | Variable to enable or disable the rate limit rule | `bool` | `false` | no |
| <a name="input_sql_injection_rule_enabled"></a> [sql\_injection\_rule\_enabled](#input\_sql\_injection\_rule\_enabled) | Variable to enable or disable the SQL injection rule | `bool` | `false` | no |
| <a name="input_target_arn"></a> [target\_arn](#input\_target\_arn) | # REQUIRED VARIABLES ## | `string` | `""` | no |
| <a name="input_unix_rule_enabled"></a> [unix\_rule\_enabled](#input\_unix\_rule\_enabled) | Variable to enable or disable the Unix rule | `bool` | `false` | no |
| <a name="input_waf_enabled"></a> [waf\_enabled](#input\_waf\_enabled) | n/a | `bool` | `false` | no |
| <a name="input_waf_name"></a> [waf\_name](#input\_waf\_name) | n/a | `string` | `"waf"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->