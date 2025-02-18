# module/main.tf

#===============================================================================
# DATA SOURCES AND LOCALS
# These help us determine available AZs and create consistent naming across resources
#===============================================================================
data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # sorted list of AZ names for consistent subnet creation
  zone_names = sort(data.aws_availability_zones.available.names)
}

#===============================================================================
# The main VPC with DNS and tenancy settings
#===============================================================================
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = var.vpc_tenancy
}

#===============================================================================
# INTERNET GATEWAY
# Required for public subnets to access the internet
#===============================================================================
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

#===============================================================================
# NAT GATEWAYS AND ELASTIC IPs
# Required for private subnets to access the internet
#===============================================================================
resource "aws_eip" "nat" {
  count  = var.private_subnets_enabled && var.create_nat_gateway ? var.availability_zone_count : 0
  domain = "vpc"
}

# Hourly fee applies to NAT gateways. See https://aws.amazon.com/vpc/pricing/.
resource "aws_nat_gateway" "this" {
  count         = var.private_subnets_enabled && var.create_nat_gateway ? var.availability_zone_count : 0

  allocation_id = element(aws_eip.nat[*].id, count.index)
  subnet_id     = element(aws_subnet.public[*].id, count.index)
  depends_on = [aws_internet_gateway.this]
}

#===============================================================================
# SUBNETS
# Creating public and private subnets across multiple AZs
#===============================================================================
resource "aws_subnet" "public" {
  count                   = var.availability_zone_count

  vpc_id                  = aws_vpc.this.id
  availability_zone       = local.zone_names[count.index]
  cidr_block              = cidrsubnet(var.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count                   = var.private_subnets_enabled ? var.availability_zone_count : 0

  vpc_id                  = aws_vpc.this.id
  availability_zone       = local.zone_names[count.index]
  cidr_block             = cidrsubnet(var.cidr_block, 8, 100 + count.index)
  map_public_ip_on_launch = false
}

#===============================================================================
# ROUTE TABLES AND ASSOCIATIONS
# Configuring routing for public and private subnets
#===============================================================================
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table" "private" {
  count  = var.private_subnets_enabled ? var.availability_zone_count : 0

  vpc_id = aws_vpc.this.id
}

resource "aws_route" "private_nat_gateway" {
  count                  = var.create_nat_gateway && var.private_subnets_enabled ? var.availability_zone_count : 0

  route_table_id         = element(aws_route_table.private[*].id, count.index)
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
}

# Route table associations with subnets #
resource "aws_route_table_association" "public" {
  count          = var.availability_zone_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_default_route_table.default.id
}

resource "aws_route_table_association" "private" {
  count          = var.private_subnets_enabled ? var.availability_zone_count : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = element(aws_route_table.private[*].id, count.index)
}

#===============================================================================
# SECURITY GROUPS
# Default security group with no ingress/egress rules as per security best practices
#===============================================================================
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id
}

