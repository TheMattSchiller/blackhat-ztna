
resource "boundary_host_catalog_static" "backend_servers" {
  name        = "backend_servers"
  description = "backend servers"
  scope_id    = var.org_scope
}