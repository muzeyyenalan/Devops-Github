output "instance_public_ip_0" {
  value = aws_instance.tf-ec2[0].public_ip
}

output "instance_public_ip_1" {
  value = aws_instance.tf-ec2[1].public_ip
}