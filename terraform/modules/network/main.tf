# Local Valuesで共通設定を定義
locals {
  common_tags = {
    Module      = "network"
    ManagedBy   = "terraform"
    Environment = var.environment
    Project     = var.project_name
  }
  
  # 環境別のサブネット設定
  subnet_configs = {
    dev = {
      public_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
      private_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
    }
    stg = {
      public_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
      private_cidrs = ["10.1.11.0/24", "10.1.12.0/24"]
    }
    prod = {
      public_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
      private_cidrs = ["10.2.11.0/24", "10.2.12.0/24"]
    }
  }
}

# Data Sourceで既存リソースを参照
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-vpc"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-igw"
    }
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(local.subnet_configs[var.environment].public_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.subnet_configs[var.environment].public_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
      Type = "Public"
    }
  )
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-rt"
    }
  )
}

# Public Subnet Route Table Association
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(local.subnet_configs[var.environment].private_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.subnet_configs[var.environment].private_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
      Type = "Private"
    }
  )
}

# Private Route Tables (AZごとに作成)
resource "aws_route_table" "private" {
  count = length(local.subnet_configs[var.environment].private_cidrs)

  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-private-rt-${count.index + 1}"
    }
  )
}

# Private Subnet Route Table Association
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# NAT Gateway用のElastic IP（enable_nat_gatewayがtrueの場合のみ作成）
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? length(local.subnet_configs[var.environment].public_cidrs) : 0
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}"
    }
  )
}

# NAT Gateway（enable_nat_gatewayがtrueの場合のみ作成）
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? length(local.subnet_configs[var.environment].public_cidrs) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Private SubnetからのNATルート（enable_nat_gatewayがtrueの場合のみ作成）
resource "aws_route" "private_nat" {
  count = var.enable_nat_gateway ? length(local.subnet_configs[var.environment].private_cidrs) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}
