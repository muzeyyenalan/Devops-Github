provider "aws" {
  region ="us-east-1"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}
#data "aws_ami" "tf_ami" {
# most_recent = true
#owners      = ["self"]
#filter {3
#  name   = "virtualization-type"
#  values = ["hvm"]
# }
#}
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
resource "aws_instance" "tf-Ec2" {
  ami = data.aws_ami.ubuntu.id
  key_name = var.key_name
  instance_type = var.instance_type
  tags = {
    "Name" = "Engin-Linux"
  }
}