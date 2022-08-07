variable "organization" {
  default = ""
}

variable "url" {
  default = ""
}

variable "kms_recovery_key_id" {
  default = ""
}

variable "scope_id" {
  default = ""
}

variable "auth_method" {
  default = ""
}

variable "backend_team" {
  type = set(string)
  default = [
    "jim",
    "mike",
    "todd",
  ]
}

variable "frontend_team" {
  type = set(string)
  default = [
    "randy",
    "susmitha",
  ]
}
