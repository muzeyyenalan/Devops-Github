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

resource "aws_instance" "control-node" {
  ami = "ami-0b0af3577fe5e3532"
  instance_type = "t2.micro"
  key_name = "oliver"
  security_groups = ["ansible-session4-secgr"]
  tags = {
    Name = "control-node"
  }
}

variable "tags" {
  default = ["db_server", "web_server"]
}

resource "aws_instance" "managed-node" {
  ami = "ami-0b0af3577fe5e3532"
  count = 2
  instance_type = "t2.micro"
  key_name = "oliver"
  security_groups = ["ansible-session4-secgr"]

tags = {
  Name = element(var.tags, count.index)
}
}

resource "aws_security_group" "tf-sec-gr" {
  name = "ansible-session4-secgr"
  tags = {
    Name = "ansible-session4-secgr"
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

  ingress {
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
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
  depends_on = [aws_instance.control-node]
  connection {
    host = aws_instance.control-node.public_ip
    type = "ssh"
    user = "ec2-user"
    private_key = file("~/oliver.pem")
    }

  provisioner "file" {
  source = "./ansible.cfg"
  destination = "/home/ec2-user/ansible.cfg"
}

  provisioner "file" {
    source = "~/.ssh/oliver.pem"
    destination = "/home/ec2-user/oliver.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname Control-Node",
      "sudo yum install -y python3",
      "pip3 install --user ansible",
      "echo [servers] > inventory.txt",
      "echo db_server  ansible_host=${aws_instance.managed-node[0].private_ip}  ansible_ssh_private_key_file=~/oliver.pem ansible_user=ec2-user >> inventory.txt",
      "echo web_server  ansible_host=${aws_instance.managed-node[1].private_ip}  ansible_ssh_private_key_file=~/oliver.pem ansible_user=ec2-user >> inventory.txt",
      "chmod 400 oliver.pem"
    ]
  }

}

output "controlnodeip" {
  value = aws_instance.control-node.public_ip
}

output "privates" {
  value = aws_instance.managed-node.*.private_ip
}
