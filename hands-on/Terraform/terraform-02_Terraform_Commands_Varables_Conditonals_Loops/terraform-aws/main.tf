provider "aws" {
  region  = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.69.0"
    }
  }
}

resource "aws_instance" "tf-ec2" {
    # ami           = "ami-0742b4e673072066f"
    ami           = "ami-042e8287309f5df03"
    instance_type = "t2.micro" 
    key_name      = "firstkey"    #<pem file>
    tags = {
      # Name = "tf-ec2"
      Name = "tf-ec2-ubuntu"
  }
}

resource "aws_s3_bucket" "tf-s3" {
  bucket = "new-tf-bucket-addwhateveryouwant-new"
  #bucket = "oliver-tf-bucket-addwhateveryouwant"
  acl    = "private"
}
output "tf_example_private_ip" {
  value = aws_instance.tf-ec2.private_ip
}

output "tf_example_s3_meta" {
  value = aws_s3_bucket.tf-s3.region
}
