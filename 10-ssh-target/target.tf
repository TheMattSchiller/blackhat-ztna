resource "boundary_target" "ssh-target" {
  type                     = "tcp"
  name                     = "ssh"
  description              = "Backend SSH target"
  scope_id                 = var.org_scope
  session_connection_limit = -1
  default_port             = 22
  host_source_ids = [boundary_host_static.target_ssh.id]
}

resource "boundary_host_static" "target_ssh" {
  name            = "target_ssh"
  host_catalog_id = var.host_catalog_id
  address         = var.target_address
}