module "tf-vpc" {
  source = "../modules"
  env    = "DEV"
}

output "vpc-cidr-block" {
  value = module.tf-vpc.vpc_cidr
}