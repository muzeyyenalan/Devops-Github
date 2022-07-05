//This Terraform Template creates a Nexus server on AWS EC2 Instance
//Nexus server will run on Amazon Linux 2 with custom security group
//allowing SSH (22) and TCP (8081) connections from anywhere.


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "tf-nexus-server" {
  ami           = "ami-0cff7528ff583bf9a"
  instance_type = "t3a.medium"
  key_name      = "tyler-team"
  vpc_security_group_ids = [aws_security_group.tf-nexus-sec-gr.id]
  tags = {
    Name = "nexus-server"
  }
  user_data = <<-EOF
  #! /bin/bash
  yum update -y
  yum install docker -y
  systemctl start docker
  systemctl enable docker
  usermod -aG docker ec2-user
  newgrp docker
  docker volume create --name nexus-data
  docker run -d -p 8081:8081 --name nexus -v nexus-data:/nexus-data sonatype/nexus3
  EOF
}


resource "null_resource" "forpasswd" {
  depends_on = [aws_instance.tf-nexus-server]

  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.tf-nexus-server.id}"
  }

  # Do not forget to define your key file path correctly!
  provisioner "local-exec" {
    command = "ssh -i ~/.ssh/tyler-team.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@${aws_instance.tf-nexus-server.public_ip} 'docker cp nexus:/nexus-data/admin.password  admin.password && cat /home/ec2-user/admin.password' > initialpasswd.txt"
  }
}



resource "aws_security_group" "tf-nexus-sec-gr" {
  name = "nexus-server-sec-gr"
  tags = {
    Name = "nexus-server-sec-gr"
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    protocol    = "tcp"
    to_port     = 8081
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "nexus" {
  value = "http://${aws_instance.tf-nexus-server.public_ip}:8081"
}