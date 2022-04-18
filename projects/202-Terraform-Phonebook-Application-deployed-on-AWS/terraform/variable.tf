variable "subnet" {
  default = true
}

variable "instance_type" {
  default = "t2.micro"
}

data "aws_ami" "my_ami"{
  most_recent = true
  owners = [ "amazon" ]

 filter {
   name = "owner-alias"
   values =  ["amazon"]
 }

 filter {
     name ="name"
     values = ["amzn2-ami-hvm*"]
   
 }

 variable "key_name" {
     default = "firstkey"

 }





  
