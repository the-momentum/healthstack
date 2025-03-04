# AWS VPC

A Terraform module for creating highly available and secure VPC infrastructure on AWS with best practices baked in.

## Features

- Multi-AZ Network Architecture: Configurable public and private subnets distributed across multiple availability zones
- Secure Access Options: EC2 Instance Connect Endpoint eliminates the need for bastion hosts
- Private Connectivity: NAT Gateways for outbound internet access from private subnets
- AWS Service Integration: VPC Endpoints for secure access to AWS services without traversing the public internet
- Network Visibility: VPC Flow Logs with configurable destinations (CloudWatch Logs/S3) and KMS encryption
- Security Controls: Properly configured security groups, network ACLs, and IAM roles

The number of public and private subnets created is determined by the `availability_zone_count` variable, which has a default value of 2 but can be configured by the user.

Specifically:
- one public subnet in each availability zone specified. By default, this means 2 public subnets (one in each of 2 AZs).
- on private subnet in each availability zone, but only if `private_subnets_enabled` is set to true (which is the default). So by default, the module creates 2 private subnets.

## Example Usage

```hcl
module "vpc" {
  source = "github.com/your-org/terraform-aws-vpc"

  vpc_name    = "my-application"
  cidr_block  = "10.0.0.0/16"

  availability_zone_count = 2
  private_subnets_enabled = true
  create_nat_gateway      = true
  create_eic_endpoint     = true

  flow_log_config = {
    cw_logs_destination_enabled = true
    s3_destination_enabled      = false
  }

  vpc_endpoint_interfaces_to_enable = [
    "ssm",
    "ssmmessages",
    "ec2messages"
  ]

  vpc_endpoint_gateways_to_enable = [
    "s3",
    "dynamodb"
  ]
}

# Add your EC2 or RDS
resource "aws_instance" "public_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.public_subnet_ids[0]
  # ...
}

resource "aws_db_instance" "postgres" {
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t4g.micro"
  db_name                = "postgres"
  username               = "postgres"
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  # ...
}
```

## EC2 Instance Connect Endpoint Security

The EC2 Instance Connect Endpoint provides secure SSH access to instances in private subnets without requiring bastion hosts or public IPs. All access is:

1. Identity-based through IAM permissions
2. Logged in AWS CloudTrail, including:
   - Who accessed the instance (IAM identity)
   - When the access occurred
   - Source IP address
   - Target instance IP address
   - Endpoint used

Example CloudTrail log entry:

```json
{
    "eventSource": "ec2-instance-connect.amazonaws.com",
    "eventName": "OpenTunnel",
    "sourceIPAddress": "146.70.144.42",
    "requestParameters": {
        "instanceConnectEndpointId": "eice-0acd2566f72f2e1d9",
        "remotePort": "22",
        "privateIpAddress": "10.0.100.144"
    }
}
```

You can connect to instances using:

```
# for EC2 with ubuntu
aws ec2-instance-connect ssh --instance-id i-123123123 --os-user ubuntu
```