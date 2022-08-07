
output "backend_users" {
  value = [
  for a in boundary_user.backend : a.account_ids
  ]
}