
resource "random_pet" "test" {
  length = 1
}

resource "aws_key_pair" "boundary" {
  key_name   = "boundary-${random_pet.test.id}"
  public_key = file(var.pub_ssh_key_path)

}

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

provider "boundary" {
  addr             = module.controller.boundary_lb_url
  recovery_kms_hcl = <<EOT
kms "awskms" {
	purpose    = "recovery"
    kms_key_id = "${module.controller.kms_recovery_key_id}"
}
EOT
}