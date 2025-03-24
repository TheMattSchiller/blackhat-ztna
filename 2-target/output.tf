output "target_instance_ip" {
  value = aws_instance.target.private_ip
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}
