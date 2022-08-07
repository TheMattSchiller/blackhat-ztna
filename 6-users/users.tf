provider "boundary" {
  addr             = var.url
  recovery_kms_hcl = <<EOT
kms "awskms" {
	purpose    = "recovery"
        kms_key_id = "${var.kms_recovery_key_id}"
}
EOT
}

resource "boundary_account_password" "standarduser" {
  auth_method_id = var.auth_method
  type           = "password"
  login_name     = "jeff"
  password       = "$uper$ecure"
}

resource "boundary_user" "standarduser" {
  name        = "standarduser"
  description = "user with typical permissions"
  account_ids = [boundary_account_password.standarduser.id]
  scope_id    = var.scope_id
}

resource "boundary_account_password" "adminuser" {
  auth_method_id = var.auth_method
  type           = "password"
  login_name     = "jeff"
  password       = "$uper$ecure"
}

resource "boundary_user" "adminuser" {
  name        = "adminuser"
  description = "user with typical permissions"
  account_ids = [boundary_account_password.adminuser.id]
  scope_id    = var.scope_id
}