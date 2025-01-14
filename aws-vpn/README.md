# AWS Client VPN

AWS Client VPN is a service that allows you to securely connect to your VPCs from anywhere using an OpenVPN-based client.

This module creates a Client VPN endpoint and a certificate authority (CA) that you can use to issue client certificates.

Using Client VPN you can connect to your VPCs from anywhere, including your home or office and reach your resources in the cloud without exposing your resources to the public internet.

## Implementation Guidelines

- Client CIDR ranges cannot overlap with the local CIDR of the VPC in which the associated subnet is located
- Client CIDR ranges must have a block size of at least /22 and must not be greater than /12.
-  Assign a CIDR block that contains **twice the number** of IP addresses that are required to enable the maximum number of concurrent connections that you plan to support on the Client VPN endpoint.
- The client CIDR range cannot be changed after you create the Client VPN endpoint.
- The subnets associated with a Client VPN endpoint must be in the same VPC.
- AWS Client VPN provides secure connections from any location using Transport Layer Security (TLS) 1.2 or later.

## Example usage

```tf
module "vpn" {
  source = "github.com/the-momentum/healthstack.git//aws-vpn/module"

  organization_name   = "Momentum"
  vpn_domain          = "vpn.myvpn.com"
  vpc_id              = "vpc-123123"
  subnet_ids          = [
    "subnet-123123",
    "subnet-456456",
  ]

  client_cidr_block   = "10.100.0.0/22"
  target_network_cidr = "172.31.0.0/16"

  tags = {
    Environment = "test"
  }
}
```

## Client configuration

Upon completing the module execution, you will receive a client configuration file for connecting to the VPN.
The file, named `client.ovpn`, contains the following components:
- CA certificate
- Client certificate
- Client key
- OpenVPN configuration

To establish the connection, you can either use the AWS VPN Client application or the OpenVPN client. To configure the AWS VPN Client application, follow these steps:

```
File -> Manage Profiles -> Add Profile -> Fill a name and add path to the client.ovpn file -> Add profile
```

Then pick the profile and click connect. If the connection is successful, you will see 'Connected' status.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.ca_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate.vpn_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_cloudwatch_log_group.vpn_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.vpn_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_ec2_client_vpn_authorization_rule.vpn_auth_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule) | resource |
| [aws_ec2_client_vpn_endpoint.vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_endpoint) | resource |
| [aws_ec2_client_vpn_network_association.vpn_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_network_association) | resource |
| [aws_security_group.vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [local_file.vpn_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_cert_request.client_csr](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_cert_request.vpn_csr](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.client_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_locally_signed_cert.vpn_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.ca_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.client_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.vpn_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [aws_ec2_client_vpn_endpoint.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_client_vpn_endpoint) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR blocks allowed to connect to the VPN endpoint (e.g., ['10.0.0.0/8', '172.16.0.0/12']) | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_certificate_validity_period_hours"></a> [certificate\_validity\_period\_hours](#input\_certificate\_validity\_period\_hours) | Validity period for client certificates in hours (default is 1 year) | `number` | `8760` | no |
| <a name="input_client_cidr_block"></a> [client\_cidr\_block](#input\_client\_cidr\_block) | CIDR block from which client IP addresses will be assigned when connected to VPN | `string` | n/a | yes |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Organization name to be used in certificate generation (e.g., 'Example Corp') | `string` | n/a | yes |
| <a name="input_split_tunnel"></a> [split\_tunnel](#input\_split\_tunnel) | Whether to enable split tunnel mode. This allows client to access public internet and private resources. | `bool` | `true` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs where VPN endpoint network interfaces will be created | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to apply to all resources created by this module | `map(string)` | `{}` | no |
| <a name="input_target_network_cidr"></a> [target\_network\_cidr](#input\_target\_network\_cidr) | CIDR block of the VPC network that VPN clients will have access to | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the VPN endpoint will be deployed | `string` | n/a | yes |
| <a name="input_vpn_domain"></a> [vpn\_domain](#input\_vpn\_domain) | Domain name to use for VPN certificate generation (e.g., 'vpn.example.com') | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_vpn_endpoint_dns_name"></a> [client\_vpn\_endpoint\_dns\_name](#output\_client\_vpn\_endpoint\_dns\_name) | The DNS name of the Client VPN endpoint |
| <a name="output_client_vpn_endpoint_id"></a> [client\_vpn\_endpoint\_id](#output\_client\_vpn\_endpoint\_id) | The ID of the Client VPN endpoint |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group created for the VPN endpoint |
