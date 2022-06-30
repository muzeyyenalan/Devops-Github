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
  yum install java-1.8.0-openjdk -y
  wget https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
  sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
  cd /opt && yum install apache-maven -y
  wget -O nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz
  tar xvzf nexus.tar.gz
  rm nexus.tar.gz
  mv nexus-3* nexus
  chown -R ec2-user:ec2-user /opt/nexus
  chown -R ec2-user:ec2-user /opt/sonatype-work
  export PATH=$PATH:/opt/nexus/bin
  cd /opt && nexus start
  EOF
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