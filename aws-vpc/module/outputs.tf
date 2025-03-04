#===============================================================================
# VPC
#===============================================================================

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.this.arn
}

#===============================================================================
# SUBNETS
#===============================================================================

output "public_subnet_ids" {
  description = "List of public subnet IDs, in order of availability zones"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks, in order of availability zones"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs, in order of availability zones. Empty if private subnets are disabled"
  value       = var.private_subnets_enabled ? aws_subnet.private[*].id : []
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks, in order of availability zones. Empty if private subnets are disabled"
  value       = var.private_subnets_enabled ? aws_subnet.private[*].cidr_block : []
}

output "availability_zones" {
  description = "List of availability zones used by this VPC"
  value       = slice(local.zone_names, 0, var.availability_zone_count)
}

#===============================================================================
# ROUTE TABLES
#===============================================================================

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_default_route_table.default.id
}

output "private_route_table_ids" {
  description = "List of private route table IDs, in order of availability zones. Empty if private subnets are disabled"
  value       = var.private_subnets_enabled ? aws_route_table.private[*].id : []
}

#===============================================================================
# NAT GATEWAYS
#===============================================================================

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs, in order of availability zones. Empty if NAT Gateways are disabled"
  value       = var.create_nat_gateway && var.private_subnets_enabled ? aws_nat_gateway.this[*].id : []
}

output "nat_gateway_public_ips" {
  description = "List of public IP addresses of NAT Gateways, in order of availability zones. Empty if NAT Gateways are disabled"
  value       = var.create_nat_gateway && var.private_subnets_enabled ? aws_eip.nat[*].public_ip : []
}

#===============================================================================
# EC2 INSTANCE CONNECT ENDPOINT
#===============================================================================

output "eic_endpoint_id" {
  description = "ID of the EC2 Instance Connect Endpoint. Null if endpoint is not created"
  value       = try(aws_ec2_instance_connect_endpoint.this[0].id, null)
}

output "eic_endpoint_dns" {
  description = "DNS name of the EC2 Instance Connect Endpoint. Null if endpoint is not created"
  value       = try(aws_ec2_instance_connect_endpoint.this[0].dns_name, null)
}

#===============================================================================
# VPC ENDPOINTS
#===============================================================================

output "vpc_endpoint_interface_ids" {
  description = "Map of service names to Interface VPC Endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.interfaces : k => v.id }
}

output "vpc_endpoint_gateway_ids" {
  description = "Map of service names to Gateway VPC Endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.gateways : k => v.id }
}

#===============================================================================
# FLOW LOGS
#===============================================================================

output "flow_log_cloudwatch_group_name" {
  description = "Name of the CloudWatch Log Group for VPC Flow Logs. Null if CloudWatch logging is disabled"
  value       = try(aws_cloudwatch_log_group.vpc_flow_log[0].name, null)
}

output "flow_log_cloudwatch_arn" {
  description = "ARN of the CloudWatch Log Group for VPC Flow Logs. Null if CloudWatch logging is disabled"
  value       = try(aws_cloudwatch_log_group.vpc_flow_log[0].arn, null)
}

#===============================================================================
# KMS KEY
#===============================================================================

output "flow_log_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt VPC Flow Logs in CloudWatch. Null if encryption is disabled or an external key is used."
  value       = try(aws_kms_key.cloudwatch_logs[0].arn, null)
}

output "flow_log_kms_key_id" {
  description = "ID of the KMS key used to encrypt VPC Flow Logs in CloudWatch. Null if encryption is disabled or an external key is used."
  value       = try(aws_kms_key.cloudwatch_logs[0].key_id, null)
}