provider "boundary" {
  addr             = var.url
  recovery_kms_hcl = <<EOT
kms "awskms" {
	purpose    = "recovery"
        kms_key_id = "${var.kms_recovery_key_id}"
}
EOT
}

resource "boundary_auth_method" "password" {
  name        = "username_password"
  description = "Usernames and passwords local to boundary"
  type        = "password"
  scope_id    = boundary_scope.org.id
}

resource "boundary_scope" "global" {
  global_scope = true
  name         = "global"
  scope_id     = "global"
}

resource "boundary_scope" "org" {
  scope_id    = boundary_scope.global.id
  name        = var.organization
  description = "Organization scope"
}