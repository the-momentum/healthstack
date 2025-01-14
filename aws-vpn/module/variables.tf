variable "organization_name" {
  description = "Organization name for certificate generation"
  type        = string
}

variable "vpn_domain" {
  description = "Domain name for VPN certificates"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the VPN endpoint will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for VPN association"
  type        = string
}

variable "client_cidr_block" {
  description = "CIDR block for VPN client IP assignment"
  type        = string
  default     = "10.100.0.0/22"
}

variable "target_network_cidr" {
  description = "CIDR block for the target network that VPN clients can access"
  type        = string
}

variable "certificate_validity_period_hours" {
  description = "Validity period for certificates in hours"
  type        = number
  default     = 8760 # 1 year
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}