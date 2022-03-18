data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.main_cidr_block

  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_cidr_blocks)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_cidr_blocks[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_${count.index + 1}"
  }
}

resource "aws_security_group" "main_sg" {
  name        = "allow_connection"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_route"
  }
}

resource "aws_route_table_association" "public_route_association" {
  count          = length(var.public_cidr_blocks)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route.id
}
