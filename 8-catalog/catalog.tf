provider "boundary" {
  addr             = var.url
  recovery_kms_hcl = <<EOT
kms "awskms" {
	purpose    = "recovery"
        kms_key_id = "${var.kms_recovery_key_id}"
}
EOT
}

resource "boundary_host_catalog_static" "backend_servers" {
  name        = "backend_servers"
  description = "backend servers"
  scope_id    = var.org_scope
}