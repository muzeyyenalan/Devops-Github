provider "aws" {
  region ="us-east-1"
}


terraform {
  required_providers{
      aws = {
          source  = "hashicorp/aws"
          version = "4.8.0"
      }
  }
backend "s3" {
    bucket = "tf-remote-s3-bucket-muzeyyen"
    key = "env/dev/tf-remote-backend.tfstate"
    region = "us-east-1"
    dynamodb_table = "tf-s3-app-lock"
    encrypt = true
  }
}

data "aws_ami" "tf_ami" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}
locals {
  mytag = "Test"

}

resource "aws_instance" "tf-ec2" {
  ami           = data.aws_ami.tf_ami.id
  instance_type = var.instance_type
  key_name      = var.key_name
  tags = {
    Name = "${local.mytag}-this is from my-ami"
  }
}
