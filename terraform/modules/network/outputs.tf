output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPCのCIDRブロック"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "パブリックサブネットIDのリスト"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "プライベートサブネットIDのリスト"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "パブリックサブネットのCIDRブロックのリスト"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "プライベートサブネットのCIDRブロックのリスト"
  value       = aws_subnet.private[*].cidr_block
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDのリスト"
  value       = aws_nat_gateway.main[*].id
}

output "public_route_table_id" {
  description = "パブリックルートテーブルID"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "プライベートルートテーブルIDのリスト"
  value       = aws_route_table.private[*].id
}
