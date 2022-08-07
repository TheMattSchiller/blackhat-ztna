provider "boundary" {
  addr             = var.url
  recovery_kms_hcl = <<EOT
kms "awskms" {
	purpose    = "recovery"
        kms_key_id = "${var.kms_recovery_key_id}"
}
EOT
}

resource "boundary_host_static" "target" {
  name            = "target"
  host_catalog_id = var.host_catalog_id
  address         = var.target_address
}

resource "boundary_target" "backend_servers_website" {
  type                     = "tcp"
  name                     = "target_web"
  description              = "target website"
  scope_id                 = var.org_scope
  session_connection_limit = -1
  default_port             = 80
  host_source_ids = [boundary_host_static.target.id]
}

resource "boundary_host_set_static" "target_web" {
  name            = "target_web"
  host_catalog_id = var.host_catalog_id

  host_ids = [
    boundary_host_static.target.id,
  ]
}