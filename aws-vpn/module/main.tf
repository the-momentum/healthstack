################################################################################
# CA Key and Certificate (Root CA)
################################################################################

resource "tls_private_key" "ca_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem = tls_private_key.ca_key.private_key_pem

  subject {
    common_name  = "VPN Root CA"
    organization = var.organization_name
    country      = "US" # Added for compliance
  }

  validity_period_hours = 87600 # 10 years
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
    "key_encipherment"
  ]
}

################################################################################
# VPN Gateway Key and Certificate
################################################################################

resource "tls_private_key" "vpn_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "vpn_csr" {
  private_key_pem = tls_private_key.vpn_key.private_key_pem

  subject {
    common_name  = var.vpn_domain
    organization = var.organization_name
    country      = "US"
  }
}

resource "tls_locally_signed_cert" "vpn_cert" {
  cert_request_pem   = tls_cert_request.vpn_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]

  set_subject_key_id = true
}

################################################################################
# Client Key and Certificate
################################################################################

resource "tls_private_key" "client_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "client_csr" {
  private_key_pem = tls_private_key.client_key.private_key_pem

  subject {
    common_name  = "client.${var.vpn_domain}"
    organization = var.organization_name
    country      = "US"
  }
}


resource "tls_locally_signed_cert" "client_cert" {
  cert_request_pem   = tls_cert_request.client_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = var.certificate_validity_period_hours

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth",
  ]

  set_subject_key_id = true
}

################################################################################
# Import Certificates to ACM
################################################################################

resource "aws_acm_certificate" "vpn_cert" {
  private_key       = tls_private_key.vpn_key.private_key_pem
  certificate_body  = tls_locally_signed_cert.vpn_cert.cert_pem
  certificate_chain = tls_self_signed_cert.ca_cert.cert_pem

  tags = var.tags
}

resource "aws_acm_certificate" "ca_cert" {
  private_key      = tls_private_key.ca_key.private_key_pem
  certificate_body = tls_self_signed_cert.ca_cert.cert_pem

  tags = var.tags
}

# ################################################################################
# # Export Certificates to Local
# ################################################################################

# resource "local_file" "client_cert" {
#   content  = tls_locally_signed_cert.client_cert.cert_pem
#   filename = "${path.module}/certs/client.crt"
# }

# resource "local_file" "client_key" {
#   content         = tls_private_key.client_key.private_key_pem
#   filename        = "${path.module}/certs/client.key"
#   file_permission = "0600"
# }

################################################################################
# Create VPN Endpoint #
################################################################################

resource "aws_security_group" "vpn" {
  name_prefix = "client-vpn-endpoint-sg"
  description = "Security group for Client VPN endpoint"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description            = "Client VPN endpoint"
  server_certificate_arn = aws_acm_certificate.vpn_cert.arn
  client_cidr_block      = var.client_cidr_block
  vpc_id                 = var.vpc_id
  split_tunnel           = var.split_tunnel

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.ca_cert.arn
  }

  transport_protocol = "udp"
  security_group_ids = [aws_security_group.vpn.id]

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.vpn_logs.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.vpn_logs.name
  }

  dns_servers = ["169.254.169.253"]

  session_timeout_hours = 8

  client_login_banner_options {
    enabled     = true
    banner_text = "This VPN is for authorized users only. All activities may be monitored and recorded."
  }

  tags = merge(var.tags, {
    Name = "client-vpn-${var.vpn_domain}"
  })
}

resource "aws_ec2_client_vpn_network_association" "vpn_subnet" {
  for_each               = toset(var.subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id              = each.value
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr    = var.target_network_cidr
  authorize_all_groups   = true
}

################################################################################
# Logging
################################################################################

resource "aws_cloudwatch_log_group" "vpn_logs" {
  # encrypted by default
  name              = "/aws/vpn/${var.vpn_domain}"
  retention_in_days = 2192 # 6 years

  tags = var.tags
}

resource "aws_cloudwatch_log_stream" "vpn_logs" {
  name           = "vpn-connection-logs"
  log_group_name = aws_cloudwatch_log_group.vpn_logs.name
}

################################################################################
# Generate Client VPN Config File
################################################################################

data "aws_ec2_client_vpn_endpoint" "selected" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id

  depends_on = [
    aws_ec2_client_vpn_endpoint.vpn
  ]
}

resource "local_file" "vpn_config" {
  filename = "${path.root}/client.ovpn"
  content  = <<-EOT
client
dev tun
proto udp
remote ${aws_ec2_client_vpn_endpoint.vpn.dns_name} 443
remote-random-hostname
resolv-retry infinite
nobind
remote-cert-tls server
cipher AES-256-GCM
verify-x509-name ${var.vpn_domain} name
reneg-sec 0
verb 3

<ca>
${tls_self_signed_cert.ca_cert.cert_pem}
</ca>

<cert>
${tls_locally_signed_cert.client_cert.cert_pem}
</cert>

<key>
${tls_private_key.client_key.private_key_pem}
</key>
EOT

  file_permission = "0600"

  depends_on = [
    aws_ec2_client_vpn_endpoint.vpn,
    tls_locally_signed_cert.client_cert,
    tls_private_key.client_key,
    tls_self_signed_cert.ca_cert
  ]
}