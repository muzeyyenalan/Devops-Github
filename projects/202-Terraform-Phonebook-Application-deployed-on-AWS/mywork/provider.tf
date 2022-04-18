terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.10.0"
    }
  }
}

provider "aws" {
  # Configuration options
}
provider "github" {
  token = "xxxxxxxxxxxxxxxxxxxxx"
}