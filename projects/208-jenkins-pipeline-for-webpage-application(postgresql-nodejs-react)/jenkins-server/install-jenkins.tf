provider "aws" {
  region = "us-east-2"
  profile = "cw-training"
}

resource "aws_iam_role" "aws_access" {
  name = "awsrole"
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
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess", "arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/IAMFullAccess"]

}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "jenkins-profile"
  role = aws_iam_role.aws_access.name
}

resource "aws_instance" "tf-jenkins-server" {
//  ami           = data.aws_ami.tf-ami.id
  ami = "ami-0661cd3308ec33aaa"
  instance_type = "t3a.medium"
//  key_name      = "oliver"
  key_name      = "oliver-ohio"
  //  Write your pem file name
  security_groups = ["jenkins-server-sec-gr"]
  iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
  tags = {
    Name = "Jenkins_Server"
  }
  user_data = file("install-jenkins.sh")

}

resource "aws_security_group" "tf-jenkins-sec-gr" {
  name = "jenkins-server-sec-gr"
  tags = {
    Name = "jenkins-server-sec-group"
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
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//resource "null_resource" "jenkins-config" {
//  connection {
//    host = aws_instance.tf-jenkins-server.public_ip
//    type = "ssh"
//    user = "ec2-user"
////    private_key = file("~/oliver.pem")
//    private_key = file("~/oliver-ohio.pem")
//  }
//
//
////  provisioner "file" {
////    source = "~/oliver.pem"
////    destination = "/home/ec2-user/oliver.pem"
////  }
//
//  provisioner "file" {
//    source = "~/oliver-ohio.pem"
//    destination = "/home/ec2-user/oliver-ohio.pem"
//  }
//
//
////  provisioner "remote-exec" {
////    inline = [
////      "chmod 400 oliver.pem"
////    ]
////  }
//
//  provisioner "remote-exec" {
//    inline = [
//     "chmod 400 oliver-ohio.pem"
//    ]
//  }
//}

output "jenkins-server" {
  value = "http://${aws_instance.tf-jenkins-server.public_dns}:8080"
}