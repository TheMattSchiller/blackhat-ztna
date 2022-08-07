
resource "boundary_target" "backend_servers_ssh" {
  type                     = "tcp"
  name                     = "backend_servers_ssh"
  description              = "Backend SSH target"
  scope_id                 = var.org_scope
  session_connection_limit = -1
  default_port             = 22
  host_source_ids = var.host_source_ids
}
