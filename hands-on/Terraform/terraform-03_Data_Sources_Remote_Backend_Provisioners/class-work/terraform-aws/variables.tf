variable "ec2_name" {
  default = "oliver-ec2"
}

variable "ec2_type" {
  default = "t2.micro"
}

variable "ec2_ami" {
  default = "ami-0742b4e673072066f"
}

variable "s3_bucket_name" {
#  default = "murat-s3-bucket-variable"
}

variable "num_of_buckets" {
  default = 2
}

variable "users" {
  default = ["santino", "michael", "fredo", "michael"]
}