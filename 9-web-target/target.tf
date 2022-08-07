locals {
  priv_ssh_key_real = coalesce(var.priv_ssh_key_path, trimsuffix(var.pub_ssh_key_path, ".pub"))
}

provider "boundary" {
  addr             = var.url
  recovery_kms_hcl = <<EOT
kms "awskms" {
	purpose    = "recovery"
        kms_key_id = "${var.kms_recovery_key_id}"
}
EOT
}

resource "boundary_host_static" "target" {
  name            = "target"
  host_catalog_id = var.host_catalog_id
  address         = aws_instance.web.private_ip
}

resource "boundary_target" "target_web" {
  type                     = "tcp"
  name                     = "target_web"
  description              = "target website"
  scope_id                 = var.org_scope
  session_connection_limit = -1
  default_port             = 80
  host_source_ids = [boundary_host_static.target.id]
}

resource "boundary_host_set_static" "target_web" {
  name            = "target_web"
  host_catalog_id = var.host_catalog_id

  host_ids = [
    boundary_host_static.target.id,
  ]
}

resource "aws_instance" "web" {
  ami                         = var.ami
  instance_type               = "t3.micro"
  subnet_id                   = var.private_subnet
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [var.vpc_security_group]
  associate_public_ip_address = true

  connection {
    type         = "ssh"
    user         = "ubuntu"
    private_key  = file(local.priv_ssh_key_real)
    host         = self.private_ip
    bastion_host = var.controller_ip
  }
}