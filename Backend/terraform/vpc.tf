resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "${var.aws_region}b"
    map_public_ip_on_launch = true
    tags = {
      Name = "public-subnet-2"
      "kubernetes.io/role/elb" = "1"
    }
}

resource "aws_subnet" "private_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.10.0/24"
    availability_zone = "${var.aws_region}a"
    tags = {
      Name = "private-subnet-1"
      "kubernetes.io/role/internal-elb" = "1"
    }
}

resource "aws_subnet" "private_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.11.0/24"
    availability_zone = "${var.aws_region}b"
    tags = {
      Name = "private-subnet-2"
      "kubernetes.io/role/internal-elb" = "1"
    }
}

resource "aws_subnet" "private_db_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.20.0/24"
    availability_zone = "${var.aws_region}a"
    tags = {
      Name = "private-db-1"
    }
}

resource "aws_subnet" "private_db_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.21.0/24"
    availability_zone = "${var.aws_region}b"
    tags = {
      Name = "private-db-2"
    }
}

resource "aws_eip" "nat_1" {
  domain = "vpc"
}
resource "aws_eip" "nat_2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id = aws_subnet.public_1.id
  depends_on = [ aws_internet_gateway.igw ]
}
resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id = aws_subnet.public_2.id
  depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }
}

resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2.id
  }
}

resource "aws_route_table_association" "pub_1" {
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.publicrt.id
}

resource "aws_route_table_association" "pub_2" {
  subnet_id = aws_subnet.public_2.id
  route_table_id = aws_route_table.publicrt.id
}

resource "aws_route_table_association" "prv_app_1" {
  subnet_id = aws_subnet.private_1.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "prv_app_2" {
  subnet_id = aws_subnet.private_2.id
  route_table_id = aws_route_table.private2.id
}