# AWS Client VPN

AWS Client VPN is a service that allows you to securely connect to your VPCs from anywhere.

This module creates a Client VPN endpoint and a certificate authority (CA) that you can use to issue client certificates.

Using Client VPN you can connect to your VPCs from anywhere, including your home or office and reach your resources in the cloud without exposing your resources to the public internet.

## Example usage

```tf
module "vpn" {
  source = "github.com/momentum-ai/healthstack.git//aws-vpn/module"

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

## Example usage

## Client configuration

