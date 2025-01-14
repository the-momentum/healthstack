variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to the VPN endpoint (e.g., ['10.0.0.0/8', '172.16.0.0/12'])"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "certificate_validity_period_hours" {
  description = "Validity period for client certificates in hours (default is 1 year)"
  type        = number
  default     = 8760
}

variable "client_cidr_block" {
  description = "CIDR block from which client IP addresses will be assigned when connected to VPN"
  type        = string
}

variable "organization_name" {
  description = "Organization name to be used in certificate generation (e.g., 'Example Corp')"
  type        = string
}

variable "split_tunnel" {
  description = "Whether to enable split tunnel mode. This allows client to access public internet and private resources."
  type        = bool
  default     = true
}


variable "subnet_ids" {
  description = "List of subnet IDs where VPN endpoint network interfaces will be created"
  type        = list(string)
}

variable "tags" {
  description = "Map of tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}

variable "target_network_cidr" {
  description = "CIDR block of the VPC network that VPN clients will have access to"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the VPN endpoint will be deployed"
  type        = string
}

variable "vpn_domain" {
  description = "Domain name to use for VPN certificate generation (e.g., 'vpn.example.com')"
  type        = string
}
