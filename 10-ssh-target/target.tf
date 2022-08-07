provider "boundary" {
  addr             = var.url
  recovery_kms_hcl = <<EOT
kms "awskms" {
	purpose    = "recovery"
        kms_key_id = "${var.kms_recovery_key_id}"
}
EOT
}


resource "boundary_host_set_static" "target_ssh" {
  name            = "target_ssh"
  host_catalog_id = var.host_catalog_id

  host_ids = [
    var.target_host_id,
  ]
}