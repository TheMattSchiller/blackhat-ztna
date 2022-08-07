provider "boundary" {
  addr             = var.url
  recovery_kms_hcl = <<EOT
kms "awskms" {
	purpose    = "recovery"
        kms_key_id = "${var.kms_recovery_key_id}"
}
EOT
}

resource "boundary_target" "target_ssh" {
  type                     = "tcp"
  name                     = "target_ssh"
  description              = "Backend SSH target"
  scope_id                 = var.org_scope
  session_connection_limit = -1
  default_port             = 22
  host_source_ids = var.host_source_ids
}

resource "boundary_host_set_static" "target_ssh" {
  name            = "target_ssh"
  host_catalog_id = var.host_catalog_id

  host_ids = [
    var.target_host_id,
  ]
}