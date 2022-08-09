resource "boundary_host_static" "target_rdp" {
  name            = "target_rdp"
  host_catalog_id = var.host_catalog_id
  address         = aws_instance.rdp.private_ip
}

resource "boundary_target" "target_rdp" {
  type                     = "tcp"
  name                     = "rdp-server"
  description              = "a windows server"
  scope_id                 = var.project_scope
  session_connection_limit = -1
  default_port             = 3389
  host_source_ids          = [boundary_host_set_static.target_rdp.id]
}

resource "boundary_host_set_static" "target_rdp" {
  name            = "target_rdp"
  host_catalog_id = var.host_catalog_id

  host_ids = [
    boundary_host_static.target_rdp.id,
  ]
}

# Get latest Windows Server 2022 AMI
data "aws_ami" "windows-2022" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base*"]
  }
}

resource "aws_instance" "rdp" {
  ami                    = data.aws_ami.windows-2022.id
  instance_type          = "t2.medium"
  subnet_id              = var.private_subnet
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [var.vpc_security_group]

  tags = {
    Name = "rdp-server"
  }

}