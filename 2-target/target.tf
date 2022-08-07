# Example resource for connecting to through boundary over SSH
resource "aws_instance" "target" {
  ami           = var.ami
  instance_type = "t3.micro"
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  vpc_security_group_ids = [var.vpc_security_group]

  tags = {
    Name = "target-instance"
  }
}
