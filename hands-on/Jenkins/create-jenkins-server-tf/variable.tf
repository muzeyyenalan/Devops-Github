//variable "aws_secret_key" {}
//variable "aws_access_key" {}
variable "region" {
  default = "us-east-2"
}
variable "mykey" {
  default = "alexd"
}
variable "tags" {
  default = "jenkins-server"
}
variable "myami" {
  description = "amazon linux 2 ami"
  default = "ami-0022f774911c1d690"
}
variable "instancetype" {
  default = "t2.micro"
}

variable "secgrname" {
  default = "jenkins-server-sec-gr"
}