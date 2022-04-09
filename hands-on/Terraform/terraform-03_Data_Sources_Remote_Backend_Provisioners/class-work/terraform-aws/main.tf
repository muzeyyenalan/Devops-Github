provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
  backend "s3" {
    bucket = "tf-remote-s3-bucket-murat"
    key = "env/dev/tf-remote-backend.tfstate"
    region = "us-east-1"
    dynamodb_table = "tf-s3-app-lock"
    encrypt = true
  }
}

locals {
    mytag = "murat-local-name"
}

#1 data "aws_ami" "tf_ami" {
#   most_recent      = true
#   owners           = ["self"]
#   filter {
#     name = "name"
#     values = ["amzn2-ami-kernel-5.10*"]
#   }
# }

data "aws_ami" "tf_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-5.10*"]
  }
}

resource "aws_instance" "tf-ec2" {
  ami           = data.aws_ami.tf_ami.id
  instance_type = var.ec2_type
  key_name      = "mk"
  tags = {
    Name = "${local.mytag}-this is from my ami"
  }
}

# resource "aws_s3_bucket" "tf-s3" {
#   # bucket = "var.s3_bucket_name.${count.index}"
#   # count = var.num_of_buckets
#   # count = var.num_of_buckets != 0 ? var.num_of_buckets : 1
#   for_each = toset(var.users)
#   bucket   = "murat-tf-s3-bucket-${each.value}"
# }

# # if var.num_of_buckets !=0
# #   count = var.num_of_buckets
# # else
# #   count = 3

# resource "aws_iam_user" "new_users" {
#   for_each = toset(var.users)
#   name = each.value
# }

# output "uppercase_users" {
#   value = [for user in var.users : upper(user) if length(user) > 6]
# }