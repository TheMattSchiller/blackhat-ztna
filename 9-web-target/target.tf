locals {
  priv_ssh_key_real = coalesce(var.priv_ssh_key_path, trimsuffix(var.pub_ssh_key_path, ".pub"))
}

resource "boundary_host_static" "target_web" {
  name            = "target_web"
  host_catalog_id = var.host_catalog_id
  address         = aws_instance.web.private_ip
}

resource "boundary_target" "web-target" {
  type                     = "tcp"
  name                     = "web"
  description              = "target website"
  scope_id                 = var.org_scope
  session_connection_limit = -1
  default_port             = 80
  host_source_ids = [boundary_host_set_static.target_web.id]
}

resource "boundary_host_set_static" "target_web" {
  name            = "target_web"
  host_catalog_id = var.host_catalog_id

  host_ids = [
    boundary_host_static.target_web.id,
  ]
}

resource "aws_instance" "web" {
  ami                         = var.ami
  instance_type               = "t3.micro"
  subnet_id                   = var.private_subnet
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [var.vpc_security_group]

  connection {
    type         = "ssh"
    user         = "ubuntu"
    private_key  = file(local.priv_ssh_key_real)
    host         = self.private_ip
    bastion_host = var.controller_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y ca-certificates curl gnupg lsb-release",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "sudo echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt update -y",
      "sudo apt install -y docker-ce docker-ce-cli containerd.io ",
      "sudo systemctl enable docker.service",
      "sudo systemctl enable containerd.service",
      "INSTANCE_ID=\"web\"",
      "export PRIVATE_IP=\"$(hostname -i | awk '{print $1}')\"",
      "sleep 10",
      "sudo docker run -e INSTANCE_ID=$INSTANCE_ID -e PRIVATE_IP=$PRIVATE_IP -p 80:80 gcr.io/banyan-pub/demo-site"
    ]
  }

  tags = {
    Name = "web-server"
  }

}