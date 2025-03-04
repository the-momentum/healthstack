#===============================================================================
# EC2 INSTANCE CONNECT ENDPOINT
# Enables secure SSH access to instances in private subnets without bastion hosts
#===============================================================================
resource "aws_ec2_instance_connect_endpoint" "this" {
  count = var.create_eic_endpoint && var.private_subnets_enabled ? 1 : 0

  subnet_id          = aws_subnet.private[0].id
  security_group_ids = [aws_security_group.eic_endpoint[0].id]

  preserve_client_ip = true
}

resource "aws_security_group" "eic_endpoint" {
  count = var.create_eic_endpoint && var.private_subnets_enabled ? 1 : 0

  name        = "${var.vpc_name}-eic-endpoint-sg"
  description = "Security group for EC2 Instance Connect Endpoint"
  vpc_id      = aws_vpc.this.id

  # EC2 Instance Connect Endpoint needs outbound access to SSH to instances
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
    description = "Allow SSH to instances within VPC"
  }
}

#===============================================================================
# VPC ENDPOINTS
# Enables access to AWS services using private subnets
#===============================================================================
resource "aws_security_group" "vpc_endpoint" {
  count = length(var.vpc_endpoint_interfaces_to_enable) > 0 ? 1 : 0

  name        = "${var.vpc_name}-vpc-endpoint-sg"
  description = "Rules for VPC endpoint traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Additional fees apply. See https://aws.amazon.com/privatelink/pricing/.
resource "aws_vpc_endpoint" "interfaces" {
  for_each = toset(var.vpc_endpoint_interfaces_to_enable)

  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.this.id

  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.vpc_endpoint[0].id,
  ]

  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${each.key} interface"
  }
}

# AWS does not charge for gateway endpoints.
resource "aws_vpc_endpoint" "gateways" {
  for_each = toset(var.vpc_endpoint_gateways_to_enable)

  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type = "Gateway"
  vpc_id            = aws_vpc.this.id
  route_table_ids   = flatten([aws_route_table.private[*].id])

  tags = {
    Name = "${each.key} gateway"
  }
}
