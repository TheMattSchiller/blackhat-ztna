locals {
  priv_ssh_key_real = coalesce(var.priv_ssh_key_path, trimsuffix(var.pub_ssh_key_path, ".pub"))
}

resource "aws_instance" "worker-1" {
  ami                         = var.ami
  instance_type               = "t3.micro"
  iam_instance_profile        = var.aws_iam_instance_profile
  subnet_id                   = var.public_subnet
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
      "sudo apt update -y && sudo apt update -y && sudo apt install -y unzip",
      "curl -L https://releases.hashicorp.com/boundary/0.9.1/boundary_0.9.1_linux_amd64.zip --output boundary.zip",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "unzip boundary.zip",
      "mv boundary /tmp/boundary",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/boundary /usr/local/bin/boundary",
      "sudo chmod 0755 /usr/local/bin/boundary",
    ]
  }

  provisioner "file" {
    content = templatefile("${path.module}/worker/install/worker.hcl.tpl", {
      controller_ips         = [var.controller_ip]
      name_suffix            = "1"
      public_ip              = self.public_ip
      private_ip             = self.private_ip
      tls_disabled           = var.tls_disabled
      tls_key_path           = var.tls_key_path
      tls_cert_path          = var.tls_cert_path
      kms_type               = var.kms_type
      kms_worker_auth_key_id = var.kms_worker_auth_key_id
    })
    destination = "/tmp/boundary-worker.hcl"
  }

  provisioner "remote-exec" {
    inline = ["sudo mv /tmp/boundary-worker.hcl /etc/boundary-worker.hcl"]
  }

  provisioner "file" {
    source      = "${path.module}/worker/install/install.sh"
    destination = "/home/ubuntu/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 0755 /home/ubuntu/install.sh",
      "sudo /home/ubuntu/install.sh worker"
    ]
  }

  tags = {
    Name = "${var.tag}-worker"
  }

}

resource "aws_security_group" "worker" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.tag}-worker"
  }
}

resource "aws_security_group_rule" "allow_ssh_worker" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_web_worker2" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_web_worker" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_9202_worker" {
  type              = "ingress"
  from_port         = 9202
  to_port           = 9202
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_egress_worker" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}
