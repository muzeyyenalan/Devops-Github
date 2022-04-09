output "tf-example-public_ip" {
  value = aws_instance.tf-ec2.public_ip
}

output "tf_example_private_ip" {
  value = aws_instance.tf-ec2.private_ip
}

# output "tf-example-s3" {
#   value = aws_s3_bucket.tf-s3[*]
# }