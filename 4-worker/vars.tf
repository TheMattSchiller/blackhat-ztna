locals {
  tags = {
    Name = "${var.tag}"
  }

  pub_cidrs  = cidrsubnets("10.0.0.0/20", 4, 4, 4, 4)
  priv_cidrs = cidrsubnets("10.0.100.0/20", 4, 4, 4, 4)
}

variable "tag" {
  default = "boundary"
}

variable "pub_ssh_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "priv_ssh_key_path" {
  default = ""
}

variable "tls_cert_path" {
  default = "/etc/pki/tls/boundary/boundary.cert"
}

variable "tls_key_path" {
  default = "/etc/pki/tls/boundary/boundary.key"
}

variable "tls_disabled" {
  default = true
}

variable "kms_type" {
  default = "aws"
}

variable "organization" {
  default = "organization"
}

variable "private_subnet" {
  default = ""
}

variable "aws_iam_instance_profile" {
  default = ""
}

variable "private_key_pem" {
  default = ""
}

variable "cert_pem" {
  default = ""
}

variable "kms_root_key_id" {
  default = ""
}

variable "kms_recovery_key_id" {
  default = ""
}

variable "kms_worker_auth_key_id" {
  default = ""
}

variable "db_endpoint" {
  default = ""
}

variable "vpc_id" {
  default = ""
}

variable "ami" {
  default = ""
}


variable "controller_ip" {
  default = ""
}

variable "ssh_key_name" {
  default = ""
}