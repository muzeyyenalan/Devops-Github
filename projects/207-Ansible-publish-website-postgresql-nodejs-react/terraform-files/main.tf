//This Terraform Template creates 4 Ansible Machines on EC2 Instances
//Ansible Machines will run on Red Hat Enterprise Linux 8 with custom security group
//allowing SSH (22), 5000, 3000 and 5432 connections from anywhere.
//User needs to select appropriate variables form "tfvars" file when launching the instance.

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
  #  secret_key = ""
  #  access_key = ""
}

resource "aws_instance" "control_node" {
<<<<<<< HEAD
  ami = "ami-0f095f89ae15be883"
  instance_type = "t2.medium"
  key_name = "firstkey"
=======
  ami = var.myami
  instance_type = var.controlinstancetype
  key_name = var.mykey
>>>>>>> 8eb9fe008189ea95f3340e1f39a75f59a212de6e
  iam_instance_profile = aws_iam_instance_profile.ec2full.name
  vpc_security_group_ids = [aws_security_group.tf-sec-gr.id]
  tags = {
    Name = "ansible_control"
    stack = "ansible_project"
  }
}
<<<<<<< HEAD
resource "aws_instance" "managed_nodes" {
  ami = "ami-0f095f89ae15be883"
  count = 3
  instance_type = "t2.micro"
  key_name ="firstkey"
=======

resource "aws_instance" "nodes" {
  ami = var.myami
  instance_type = var.instancetype
  count = var.num
  key_name = var.mykey
>>>>>>> 8eb9fe008189ea95f3340e1f39a75f59a212de6e
  vpc_security_group_ids = [aws_security_group.tf-sec-gr.id]
  tags = {
    Name = "ansible_${element(var.tags, count.index )}"
    stack = "ansible_project"
    environment = "development"
  }
  user_data = file("userdata.sh")
}

resource "aws_iam_role" "ec2full" {
  name = "projectec2full"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
}

resource "aws_iam_instance_profile" "ec2full" {
  name = "projectec2full"
  role = aws_iam_role.ec2full.name
}

resource "aws_security_group" "tf-sec-gr" {
<<<<<<< HEAD
  name = "project207-sec-gr-firstkey"
  tags = {
    Name = "project207-sec-gr-firstkey"
=======
  name = var.mysecgr
  tags = {
    Name = var.mysecgr
>>>>>>> 8eb9fe008189ea95f3340e1f39a75f59a212de6e
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5000
    protocol    = "tcp"
    to_port     = 5000
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    protocol    = "tcp"
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5432
    protocol    = "tcp"
    to_port     = 5432
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "config" {
  depends_on = [aws_instance.control_node]
  connection {
    host = aws_instance.control_node.public_ip
    type = "ssh"
    user = "ec2-user"
<<<<<<< HEAD
    private_key = file("~/.ssh/firstkey.pem")
=======
    private_key = file("~/.ssh/${var.mykeypem}")
    # Do not forget to define your key file path correctly!
>>>>>>> 8eb9fe008189ea95f3340e1f39a75f59a212de6e
  }

  provisioner "file" {
    source = "./ansible.cfg"
    destination = "/home/ec2-user/.ansible.cfg"
  }

  provisioner "file" {
    source = "./inventory_aws_ec2.yml"
    destination = "/home/ec2-user/inventory_aws_ec2.yml"
  }

  provisioner "file" {
<<<<<<< HEAD
    source = "~/.ssh/firstkey.pem"
    destination = "/home/ec2-user/firstkey.pem"
=======
    # Do not forget to define your key file path correctly!
    source = "~/.ssh/${var.mykeypem}"
    destination = "/home/ec2-user/${var.mykeypem}"
>>>>>>> 8eb9fe008189ea95f3340e1f39a75f59a212de6e
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname Control-Node",
      "sudo yum install -y python3",
      "pip3 install --user ansible",
      "pip3 install --user boto3",
<<<<<<< HEAD
      "chmod 400 firstkey.pem"
=======
      "chmod 400 ${var.mykeypem}"
>>>>>>> 8eb9fe008189ea95f3340e1f39a75f59a212de6e
    ]
  }

}

output "controlnodeip" {
  value = aws_instance.control_node.public_ip
}

output "privates" {
  value = aws_instance.control_node.*.private_ip
}
