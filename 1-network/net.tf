provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC resources
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_subnet
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.main.id
  tags   = local.tags
}

# Subnets
resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zone_a
  cidr_block        = var.public_subnet

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.main.id
  availability_zone =var.availability_zone_b
  cidr_block        = var.public_subnet_b

  tags = {
    Name = "public-subnet-b"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zone_a
  cidr_block        = var.private_subnet

  tags = {
    Name = "private-subnet"
  }
}


resource "aws_eip" "nat" {
  tags = local.tags
}

resource "aws_nat_gateway" "private" {
  subnet_id     = aws_subnet.public_subnet_a.id
  allocation_id = aws_eip.nat.id
  tags          = local.tags
}

# Public Routes
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

# Private Routes
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_subnet" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet_b" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.private.id

  timeouts {
    create = "5m"
  }
}
