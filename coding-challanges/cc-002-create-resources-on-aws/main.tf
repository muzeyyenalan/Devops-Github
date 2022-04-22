terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.9.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "tf_ami" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name           = "owner-alias"
    values         = ["amazon"]
  }

  filter {
    name           = "name"
    values         = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "tf-ec2" {
  ami             = data.aws_ami.tf_ami.id
  count           = var.num_of_instance
  instance_type   = var.ec2_type
  key_name        = var.keyname
  security_groups = ["tf-intance-sg"]

  tags = {
    Name = "Terraform ${element(var.tf-tags, count.index)} Instance"
  }

  provisioner "local-exec" {
    command = "echo http://${self.public_ip} > public_ip.txt"
  }

  provisioner "local-exec" {
    command = "echo http://${self.private_ip} > private_ip.txt"
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("F:/CLA-DEVOPS/firstkey.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum -y install httpd",
      "sudo chmod -R 777 /var/www/html",
      "sudo echo 'Hello World' > /var/www/html/index.html",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]
  }

  provisioner "file" {
    content     = self.public_ip
    destination = "/home/ec2-user/my_public_ip.txt"
  }

  provisioner "file" {
    content     = self.private_ip
    destination = "/home/ec2-user/my_private_ip.txt"
  }
}

resource "aws_security_group" "tf-sg" {
  name        = "tf-intance-sg"
  description = "terraform import security group"
  tags = {
    Name = "tf-sg"
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}