module "tf-vpc" {
  source = "../modules"
  env    = "PROD"
}

output "vpc-cidr-block" {
  value = module.tf-vpc.vpc_cidr
}