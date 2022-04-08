provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "fatma" {
  ami="ami-0ed9277fb7eb570c9"
  instance_type="t2.micro"
  key_name="firstkey"

}

resource "aws_security_group" "SG1" {
 ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "ssh"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}