variable "ec2_type" {
  default = "t2.micro"
}

variable "num_of_instance" {
  default = 2
}

variable "keyname" {
  default = "mk"
}

variable "tf-tags" {
  type    = list(string)
  default = ["First", "Second"]
}