resource "aws_vpc" "terraform-pro" {
  cidr_block       = "10.0.0.0/18"
  instance_tenancy = "default"

  tags = {
    name = "terraform-pro-vpc"
  }
}

resource "aws_security_group" "allow_HTTP" {
  name        = "allow_HTTP"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.terraform-pro.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.terraform-pro.cidr_block]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.terraform-pro.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow All Traffic"
  }
}

resource "aws_subnet" "terraform-pro" {
  vpc_id                  = aws_vpc.terraform-pro.id
  cidr_block              = "10.0.0.0/21"
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = true
  tags = {
    name = "terraform-pro-public1"
  }
}

resource "aws_subnet" "terraform-pro1" {
  vpc_id                  = aws_vpc.terraform-pro.id
  cidr_block              = "10.0.8.0/21"
  availability_zone       = "us-west-1b"
  map_public_ip_on_launch = true
  tags = {
    name = "terraform-pro-public2"
  }
}

resource "aws_internet_gateway" "terraform-pro-igw" {
  vpc_id = aws_vpc.terraform-pro.id

  tags = {
    Name = "terraform-pro-igw"
  }
}


resource "aws_route_table" "terraform-pro-RT" {
  vpc_id = aws_vpc.terraform-pro.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-pro-igw.id
  }

  tags = {
    Name = "terraform-pro-RT"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.terraform-pro.id
  route_table_id = aws_route_table.terraform-pro-RT.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.terraform-pro1.id
  route_table_id = aws_route_table.terraform-pro-RT.id
}







