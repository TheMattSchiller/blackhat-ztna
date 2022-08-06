output "boundary_lb_url" {
  value = "https://${aws_lb.controller.dns_name}"
}

output "kms_recovery_key_id" {
  value = aws_kms_key.recovery.id
}

output "aws_iam_instance_profile" {
  value = aws_iam_instance_profile.boundary.id
}

output "private_key_pem" {
  value = tls_private_key.boundary.private_key_pem
}

output "cert_pem" {
  value = tls_self_signed_cert.boundary.cert_pem
}

output "kms_root_key_id" {
  value = aws_kms_key.root.id
}

output "kms_worker_auth_key_id" {
  value = aws_kms_key.worker_auth.id
}

output "controller_public_ip" {
  value = aws_instance.controller.public_ip
}

output "controller_private_ip" {
  value = aws_instance.controller.private_ip
}

output "db_endpoint" {
  value = aws_db_instance.boundary.endpoint
}
