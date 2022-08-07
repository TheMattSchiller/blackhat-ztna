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

resource "boundary_scope" "project" {
  scope_id    = boundary_scope.org.id
  name        = "project"
  description = "Project scope"
  auto_create_admin_role   = true
  auto_create_default_role = true
}