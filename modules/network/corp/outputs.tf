output "dev_vpc_id" {
  value = aws_vpc.dev_vpc.id
}

output "public_dev_subnet_id" {
  value = aws_subnet.public_dev_subnet.id
}

output "private_dev_subnet_id" {
  value = aws_subnet.private_dev_subnet.id
}

output "private_eks_subnet1_id" {
  value = aws_subnet.private_eks_subnet1.id
}

output "private_eks_subnet2_id" {
  value = aws_subnet.private_eks_subnet2.id
}

output "dev_alb_dns_name" {
  value = aws_lb.dev_alb.dns_name
}

output "dev_nat_gateway_id" {
  value = aws_nat_gateway.dev_nat_gateway.id
}