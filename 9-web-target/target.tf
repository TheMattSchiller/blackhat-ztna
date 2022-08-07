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
  address         = var.target_address
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

resource "aws_instance" "worker-1" {
  ami                         = var.ami
  instance_type               = "t3.micro"
  iam_instance_profile        = var.aws_iam_instance_profile
  subnet_id                   = var.private_subnet
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.worker.id]
  associate_public_ip_address = true

  connection {
    type         = "ssh"
    user         = "ubuntu"
    private_key  = file(local.priv_ssh_key_real)
    host         = self.private_ip
    bastion_host = var.controller_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/pki/tls/boundary",
      "echo '${var.private_key_pem}' | sudo tee ${var.tls_key_path}",
      "echo '${var.cert_pem}' | sudo tee ${var.tls_cert_path}",

    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y\n",
      "sudo apt install -y ca-certificates curl gnupg lsb-release\n",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg\n",
      "sudo echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null\n",
      "sudo apt update -y\n",
      "sudo apt install -y docker-ce docker-ce-cli containerd.io \n",
      "sudo systemctl enable docker.service\n",
      "sudo systemctl enable containerd.service\n",
      "INSTANCE_ID=\"web\"\n",
      "export PRIVATE_IP=\"$(hostname -i | awk '{print $1}')\"\n",
      "docker run -e INSTANCE_ID=$INSTANCE_ID -e PRIVATE_IP=$PRIVATE_IP -p 80:80 gcr.io/banyan-pub/demo-site\n",
      "sleep 10 && sudo docker logs connector\n"
    ]
  }
}