
resource "boundary_account_password" "standarduser" {
  auth_method_id = var.auth_method
  type           = "password"
  login_name     = "standarduser"
  password       = "$uper$ecure"
}

resource "boundary_user" "standarduser" {
  name        = "standarduser"
  description = "user with typical permissions"
  account_ids = [boundary_account_password.standarduser.id]
  scope_id    = var.org_scope
}

resource "boundary_account_password" "adminuser" {
  auth_method_id = var.auth_method
  type           = "password"
  login_name     = "adminuser"
  password       = "$uper$ecure"
}

resource "boundary_user" "adminuser" {
  name        = "adminuser"
  description = "user with typical permissions"
  account_ids = [boundary_account_password.adminuser.id]
  scope_id    = var.org_scope
}