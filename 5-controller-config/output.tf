output "global_scope" {
  value   = boundary_scope.global.id
}

output "org_scope" {
  value   = boundary_scope.org.id
}

output "project_scope" {
  value   = boundary_scope.project.id
}

output "auth_method" {
  value = boundary_auth_method.password.id
}