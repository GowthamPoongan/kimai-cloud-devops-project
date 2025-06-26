provider "aws" {
  region = "us-east-1"
}

data "http" "my_ip" {
  url = "http://checkip.amazonaws.com/"
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "kimai-vpc"
  }
}

# Subnet for public Bastion
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# Subnet for private Kimai
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main-igw"
  }
}

# Route Table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Route association for public subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security group for Bastion
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH from my IP only"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

# Bastion EC2
resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]

  lifecycle {
  prevent_destroy = true
}

  tags = {
    Name = "Gowtham-BastionHost"
  }
}

# Security group for Kimai - restrict SSH from Bastion only
resource "aws_security_group" "kimai_sg" {
  name        = "kimai-sg"
  description = "Allow internal SSH and app ports"
  vpc_id      = aws_vpc.main_vpc.id

  # Allow SSH only from Bastion's subnet
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = [aws_subnet.public_subnet.cidr_block]
  }

  # Allow Kimai app access (8001)
  ingress {
    from_port       = 8001
    to_port         = 8001
    protocol        = "tcp"
    cidr_blocks     = [aws_subnet.public_subnet.cidr_block]
  }

  # Allow Jenkins access (8080)
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = [aws_subnet.public_subnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kimai-sg"
  }
}

# Kimai EC2 instance (private only)
resource "aws_instance" "kimai" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.kimai_sg.id]
  key_name               = var.key_name
  associate_public_ip_address = false
  user_data              = file("${path.module}/user_data.sh")

  tags = {
    Name = "Gowtham-KimaiServer"
  }

 lifecycle {
  prevent_destroy = true
  ignore_changes  = [
    user_data,
    iam_instance_profile
  ]
}

}

resource "aws_iam_instance_profile" "kimai_profile" {
  name = "kimai-ec2-instance-profile"
  role = aws_iam_role.kimai_role.name
}