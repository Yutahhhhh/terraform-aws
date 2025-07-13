# Elastic IPs for NAT Gateways（enable_nat_gateway が true の場合のみ作成）
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 0

  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-eip-${substr(var.availability_zones[count.index], -1, 1)}"
  }
}

# NAT Gateways（enable_nat_gateway が true の場合のみ作成）
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-${substr(var.availability_zones[count.index], -1, 1)}"
  }

  depends_on = [aws_internet_gateway.main]
}

# Private Subnetからのルート設定（enable_nat_gateway が true の場合のみ作成）
resource "aws_route" "private_nat" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}
