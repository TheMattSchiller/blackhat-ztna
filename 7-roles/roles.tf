provider "boundary" {
  addr             = var.url
  recovery_kms_hcl = <<EOT
kms "awskms" {
	purpose    = "recovery"
        kms_key_id = "${var.kms_recovery_key_id}"
}
EOT
}

# Allows anonymous (un-authenticated) users to list and authenticate against any
# auth method, list the global scope, and read and change password on their account ID
# at the global scope
resource "boundary_role" "global_anon_listing" {
  scope_id = var.global_scope
  grant_strings = [
    "id=*;type=auth-method;actions=list,authenticate",
    "type=scope;actions=list",
    "id={{account.id}};actions=read,change-password"
  ]
  principal_ids = ["u_anon"]
}

# Allows anonymous (un-authenticated) users to list and authenticate against any
# auth method, list the global scope, and read and change password on their account ID
# at the org level scope
resource "boundary_role" "org_anon_listing" {
  scope_id = var.org_scope
  grant_strings = [
    "id=*;type=auth-method;actions=list,authenticate",
    "type=scope;actions=list",
    "id={{account.id}};actions=read,change-password"
  ]
  principal_ids = ["u_anon"]
}

# Creates a role in the global scope that's granting administrative access to 
# resources in the org scope for all backend users
resource "boundary_role" "org_admin" {
  scope_id       = var.global_scope
  grant_scope_id = var.org_scope
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = [var.adminuser]
}

# Adds an org-level role granting administrative permissions within the core_infra project
resource "boundary_role" "standarduser" {
  name           = "standarduser"
  description    = "A standard role for a typical user"
  scope_id       = var.org_scope
  grant_scope_id = var.org_scope
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = [var.standarduser]
}
