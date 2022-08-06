resource "tls_private_key" "boundary" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "boundary" {
  private_key_pem = tls_private_key.boundary.private_key_pem

  subject {
    common_name  = aws_lb.controller.dns_name
    organization = var.organization
  }

  dns_names = [aws_lb.controller.dns_name]

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "local_file" "self-signed-cert" {
  content  = tls_self_signed_cert.boundary.cert_pem
  filename = "./cert.pem"
}

resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.boundary.private_key_pem
  certificate_body = tls_self_signed_cert.boundary.cert_pem

  tags = {
    Name = "${var.tag}"
  }
}
