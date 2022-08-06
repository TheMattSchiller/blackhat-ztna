locals {
  priv_ssh_key_real = coalesce(var.priv_ssh_key_path, trimsuffix(var.pub_ssh_key_path, ".pub"))
}

resource "aws_key_pair" "boundary" {
  key_name   = var.tag
  public_key = file(var.pub_ssh_key_path)

  tags = local.tags
}

resource "aws_instance" "controller" {
  ami                         = var.ami
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.boundary.id
  subnet_id                   = var.public_subnet
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.controller.id]
  associate_public_ip_address = true

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(local.priv_ssh_key_real)
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/pki/tls/boundary",
      "echo '${tls_private_key.boundary.private_key_pem}' | sudo tee ${var.tls_key_path}",
      "echo '${tls_self_signed_cert.boundary.cert_pem}' | sudo tee ${var.tls_cert_path}",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install zip unzip",
      "curl -L https://releases.hashicorp.com/boundary/0.9.1/boundary_0.9.1_linux_amd64.zip --output boundary.zip",
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
    content = templatefile("${path.module}/controller/install/controller.hcl.tpl", {
      name_suffix            = "1"
      db_endpoint            = aws_db_instance.boundary.endpoint
      private_ip             = self.private_ip
      tls_disabled           = var.tls_disabled
      tls_key_path           = var.tls_key_path
      tls_cert_path          = var.tls_cert_path
      kms_type               = var.kms_type
      kms_worker_auth_key_id = aws_kms_key.worker_auth.id
      kms_recovery_key_id    = aws_kms_key.recovery.id
      kms_root_key_id        = aws_kms_key.root.id
    })
    destination = "/tmp/boundary-controller.hcl"
  }

  provisioner "remote-exec" {
    inline = ["sudo mv /tmp/boundary-controller.hcl /etc/boundary-controller.hcl"]
  }

  provisioner "file" {
    source      = "${path.module}/controller/install/install.sh"
    destination = "/home/ubuntu/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 0755 /home/ubuntu/install.sh",
      "sudo sh /home/ubuntu/install.sh controller"
    ]
  }

  tags = {
    Name = "${var.tag}-controller"
  }
}


resource "aws_security_group" "controller" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.tag}-controller"
  }
}

resource "aws_security_group_rule" "allow_ssh_controller" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.controller.id
}

resource "aws_security_group_rule" "allow_9200_controller" {
  type              = "ingress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.controller.id
}

resource "aws_security_group_rule" "allow_9201_controller" {
  type              = "ingress"
  from_port         = 9201
  to_port           = 9201
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.controller.id
}

resource "aws_security_group_rule" "allow_egress_controller" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.controller.id
}
