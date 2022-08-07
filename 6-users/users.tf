provider "boundary" {
  addr             = var.url
  recovery_kms_hcl = <<EOT
kms "awskms" {
	purpose    = "recovery"
        kms_key_id = "${var.kms_recovery_key_id}"
}
EOT
}

resource "boundary_user" "backend" {
  for_each    = var.backend_team
  name        = each.key
  description = "Backend user: ${each.key}"
  account_ids = [boundary_account.backend_user_acct[each.value].id]
  scope_id    = var.scope_id
}

resource "boundary_user" "frontend" {
  for_each    = var.frontend_team
  name        = each.key
  description = "Frontend user: ${each.key}"
  account_ids = [boundary_account.frontend_user_acct[each.value].id]
  scope_id    = var.scope_id
}

resource "boundary_account" "backend_user_acct" {
  for_each       = var.backend_team
  name           = each.key
  description    = "User account for ${each.key}"
  type           = "password"
  login_name     = lower(each.key)
  password       = "foofoofoo"
  auth_method_id = var.auth_metod
}

resource "boundary_account" "frontend_user_acct" {
  for_each       = var.frontend_team
  name           = each.key
  description    = "User account for ${each.key}"
  type           = "password"
  login_name     = lower(each.key)
  auth_method_id = var.auth_metod
}

resource "boundary_account_password" "backend" {
  for_each       = var.backend_team
  auth_method_id = var.auth_metod
  type           = "password"
  login_name     = each.key
  password       = "foofoofoo"
}

resource "boundary_account_password" "frontend" {
  for_each       = var.frontend_team
  auth_method_id = var.auth_metod
  type           = "password"
  login_name     = each.key
  password       = "foofoofoo"
}