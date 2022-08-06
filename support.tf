
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
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}