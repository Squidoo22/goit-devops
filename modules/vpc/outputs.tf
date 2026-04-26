output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the created VPC"
}

output "public_subnets" {
  value       = aws_subnet.public[*].id
  description = "IDs of the public subnets"
}

output "private_subnets" {
  value       = aws_subnet.private[*].id
  description = "IDs of the private subnets"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.vpc_id
  description = "IDs of the private subnets"
}