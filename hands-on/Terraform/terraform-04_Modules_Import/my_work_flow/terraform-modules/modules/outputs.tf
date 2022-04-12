output "vpc_id" {
  value = aws_vpc.module_vpc.id
  description ="VPC id number"
}

output "cidr_block" {
  value = aws_vpc.module_vpc.cidr_block
  description ="VPC id number"
}

output "public_subnet_cidr" {
   value = aws_subnet.public_subnet.cidr_block
  description ="VPC public cidr block" 
}

output "private_subnet_cidr" {
   value = aws_subnet.private_subnet.cidr_block
  description ="VPC private cidr block" 
}