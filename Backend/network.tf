resource "aws_vpc" "Budget_app" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = { Name = "Budget_app_VPC"}
}

resource "aws_internet_gateway" "My_IG" {
  vpc_id = aws_vpc.Budget_app.id
  tags = {Name = "My_Budget_IG"}
}

#Public Subnet
resource "aws_subnet" "public_subnet1" {
  vpc_id = aws_vpc.Budget_app.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {name ="Public_subnet1"}
}

resource "aws_subnet" "public_subnet2" {
  vpc_id = aws_vpc.Budget_app.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"
}

resource "aws_subnet" "app_subnet1" {
  vpc_id = aws_vpc.Budget_app.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "${var.aws_region}a"
}

resource "aws_subnet" "app_subnet2" {
  vpc_id = aws_vpc.Budget_app.id
  cidr_block = "10.0.20.0/24"
  availability_zone = "${var.aws_region}b"
}

resource "aws_subnet" "private_subnet1" {
  vpc_id = aws_vpc.Budget_app.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.aws_region}c"

  tags = {name = "Private_subnet1"}
}

resource "aws_subnet" "private_subnet2" {
  vpc_id = aws_vpc.Budget_app.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "${var.aws_region}d"

  tags = {name = "Private_subnet2"}
}

resource "aws_route_table" "public_rta" {
  vpc_id = aws_vpc.Budget_app.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.My_IG.id
  }
}

resource "aws_route_table_association" "public_rta1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rta.id
}

resource "aws_route_table_association" "public_rta2" {
  subnet_id = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rta.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.Budget_app.id
  tags = {Name = "Private_RT"}
}

resource "aws_route_table_association" "private_rt1" {
  subnet_id = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt2" {
  subnet_id = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_rt.id
}