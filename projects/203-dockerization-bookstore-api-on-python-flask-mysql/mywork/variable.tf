variable "vpc_id" {
  default = "true"
}

data "aws_key_pair" "example" {
  key_name = "firstkey"
  filter {
    name   = "tag:Component"
    values = ["web"]
  }
}