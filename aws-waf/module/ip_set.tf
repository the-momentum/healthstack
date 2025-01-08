resource "aws_wafv2_ip_set" "block" {
  name               = "BlockedIps"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = var.ip_addresses_to_block
}
resource "aws_wafv2_ip_set" "allow" {
  name               = "AllowedIps"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = var.ip_addresses_to_allow
}
