output "client_vpn_endpoint_id" {
  description = "The ID of the Client VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.vpn.id
}

output "client_vpn_endpoint_dns_name" {
  description = "The DNS name of the Client VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.vpn.dns_name
}

output "security_group_id" {
  description = "The ID of the security group created for the VPN endpoint"
  value       = aws_security_group.vpn.id
}
