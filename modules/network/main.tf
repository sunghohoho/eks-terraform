################################################################################
# VPC
################################################################################
# vpc 생성
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-vpc"
  }
}

################################################################################
# public 구성
################################################################################
# 인터넷 게이트웨이 
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${var.project}-igw"
  }
}

# 퍼블릭 서브넷, 입력받은 배열 수 만큼 생성
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    "Name" = format(
    "${var.project}-pub-subnet-%s",
    substr(var.azs[count.index], -1, 1)
    ),
    "kubernetes.io/role/elb" = "1",
    "karpenter.sh/discovery" = "${var.project}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${var.project}-pub-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.azs)

  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_internet" {
  route_table_id = aws_route_table.public.id 
  gateway_id = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}

################################################################################
# private 구성
################################################################################
# private 서브넷
resource "aws_subnet" "private" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    "Name" = format(
    "${var.project}-pri-subnet-%s",
    substr(var.azs[count.index], -1, 1)
    ),
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# private route table 구성
resource "aws_route_table" "private" {
  count = length(var.azs)

  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = format(
    "${var.project}-pri-%s-rt",
    substr(var.azs[count.index], -1, 1)
    )
  }
}

# private route table에 서브넷 구성
resource "aws_route_table_association" "private" {
  count = length(var.azs)

  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# nat에 부여할 eip 생성
# resource "aws_eip" "this" {
#   tags = {
#     "Name" = "${var.project}-eip"
#   }
# }

# # nat gateway 생성
# resource "aws_nat_gateway" "this" {
#   allocation_id = aws_eip.this.id
#   subnet_id = aws_subnet.public[0].id 

#   tags = {
#     "Name" = "${var.project}-nat-gw"
#   }
# }

# # 프라이빗 서브넷에 0.0.0.0에 대한 nat 추가
# resource "aws_route" "nat" {
#   count = length(var.azs)

#   route_table_id = aws_route_table.private[count.index].id 
#   gateway_id = aws_nat_gateway.this.id
#   destination_cidr_block = "0.0.0.0/0"
# }