
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "module_vpc" {
  cidr_block       = var.vpc_cidr_block

  tags = {
    Name = "terraform-vpc-${var.env}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.module_vpc.id
  cidr_block = var.public_subnet_cidr

  tags = {
    Name = "terraform-public-subnet-${var.env}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.module_vpc.id
  cidr_block = var.private_subnet_cidr

  tags = {
    Name = "terraform-private-subnet-${var.env}"
  }
}