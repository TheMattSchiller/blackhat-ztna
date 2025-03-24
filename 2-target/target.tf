data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "terraform_remote_state" "network" {
  config = {
    path = "${path.module}/../1-network/terraform.tfstate"
  }
  backend = "local"
}

resource "aws_instance" "target" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = data.terraform_remote_state.network.outputs.private_subnet_id
  key_name      = var.key_name

  tags = {
    Name = "target-instance"
  }
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = data.terraform_remote_state.network.outputs.public_subnet_a_id
  key_name      = var.key_name
  security_groups = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  tags = {
    Name = "bastion"
  }
}

resource "aws_security_group" "bastion" {
  name = "bastion"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

