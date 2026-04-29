resource "random_integer" "randint" {
  min = 1
  max = 10
}

resource "aws_vpc" "my_vpc" {
  region     = var.region
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}-vpc-${random_integer.randint.result}"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "az_list" {
  input = data.aws_availability_zones.available.names

  result_count = 10
}

resource "aws_subnet" "my_public_subnets" {
  count = var.public_subnet_count

  vpc_id = aws_vpc.my_vpc.id

  cidr_block        = local.public_cidr[count.index]
  availability_zone = random_shuffle.az_list.result[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public_subnet-${count.index + 1}"
  }

}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.name_prefix}-internet-gateway"
  }
}

resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "${var.name_prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "pht_public_subnets_route_table_association" {
  count = var.public_subnet_count

  route_table_id = aws_route_table.my_public_route_table.id
  subnet_id      = aws_subnet.my_public_subnets[count.index].id
}


resource "aws_subnet" "my_private_subnets" {
  count = var.private_subnet_count

  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = random_shuffle.az_list.result[count.index]

  cidr_block              = local.private_cidr[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-pht-private-subnet-${count.index + 1}"
  }
}

resource "aws_eip" "my_nat_gw_eip" {
  depends_on = [aws_internet_gateway.my_igw]

  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-nat-gateway-eip"
  }
}

resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_nat_gw_eip.id

  subnet_id = aws_subnet.my_public_subnets[0].id

  tags = {
    Name = "${var.name_prefix}-nat-gateway"
  }
}

resource "aws_route_table" "my_private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }

  tags = {
    Name = "${var.name_prefix}-pht-private-route-table"
  }
}

resource "aws_route_table_association" "my_pvt_route_table_association" {
  count = var.private_subnet_count

  route_table_id = aws_route_table.my_private_route_table.id
  subnet_id      = aws_subnet.my_private_subnets[count.index].id
}

resource "aws_default_route_table" "my_default_private_route_table" {
  default_route_table_id = aws_vpc.my_vpc.default_route_table_id

  tags = {
    Name = "${var.name_prefix}-default-private-route-table"
  }
}

resource "aws_security_group" "my_public_sg" {
  for_each = local.security_groups

  name        = each.value.name
  description = each.value.description
  tags        = each.value.tags

  dynamic "ingress" {
    for_each = each.value.ingress

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}




