resource "aws_security_group" "ec2-instance-SG" {
  name        = "Ec2-SG"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.main_vpc.id
  // To Allow SSH Transport
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "default_ec2" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.tf_ami.id
  key_name      = "Engin_Linux"
  user_data     = file("./post_configuration.sh")
  vpc_security_group_ids = [
    aws_security_group.ec2-instance-SG.id
  ]
  tags = {
    "Name" = "Web Server of Bookstore"
  }
}

