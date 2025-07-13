# カスタムNetwork ACL for Public Subnets (オプション)
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Ephemeral ports for return traffic
  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-nacl"
  }
}

# カスタムNetwork ACL for Private Subnets (オプション)
resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.main.id

  # VPC内からの通信を許可
  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  # Ephemeral ports for return traffic
  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-nacl"
  }
}

# Network ACLとサブネットの関連付け (オプション)
# デフォルトのNetwork ACLを使用する場合はコメントアウト
# resource "aws_network_acl_association" "public" {
#   count = length(aws_subnet.public)
#
#   network_acl_id = aws_network_acl.public.id
#   subnet_id      = aws_subnet.public[count.index].id
# }
#
# resource "aws_network_acl_association" "private" {
#   count = length(aws_subnet.private)
#
#   network_acl_id = aws_network_acl.private.id
#   subnet_id      = aws_subnet.private[count.index].id
# }