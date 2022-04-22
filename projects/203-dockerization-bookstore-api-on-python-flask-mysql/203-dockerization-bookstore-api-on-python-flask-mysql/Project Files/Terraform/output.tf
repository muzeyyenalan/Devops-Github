output "publicip" {
  value = aws_instance.default_ec2.public_ip
}