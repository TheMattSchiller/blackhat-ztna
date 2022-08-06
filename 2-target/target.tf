# Example resource for connecting to through boundary over SSH
resource "aws_instance" "target" {
  ami           = var.ami
  instance_type = "t3.micro"
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  tags = {
    Name = "target-instance"
  }
}
