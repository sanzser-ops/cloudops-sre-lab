terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "cloudops-lab"
}

resource "aws_vpc" "lab" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "cloudops-sre-lab-vpc"
    Project = "cloudops-sre-lab"
  }
}

output "lab_name" {
  description = "Name of the CloudOps and SRE lab"
  value       = "cloudops-sre-lab"
}

output "environment" {
  description = "Target environment"
  value       = "aws"
}

output "vpc_id" {
  description = "ID of the lab VPC"
  value       = aws_vpc.lab.id
}

output "vpc_cidr" {
  description = "CIDR block of the lab VPC"
  value       = aws_vpc.lab.cidr_block
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "cloudops-sre-lab-public-subnet"
    Project = "cloudops-sre-lab"
  }
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}
resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name    = "cloudops-sre-lab-igw"
    Project = "cloudops-sre-lab"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }

  tags = {
    Name    = "cloudops-sre-lab-public-rt"
    Project = "cloudops-sre-lab"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
output "internet_gateway_id" {
  description = "ID of the lab Internet Gateway"
  value       = aws_internet_gateway.lab.id
}
resource "aws_security_group" "lab" {
  name        = "cloudops-sre-lab-sg"
  description = "Restricted SSH access for the CloudOps SRE lab"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH from my public IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["113.203.182.254/32"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "cloudops-sre-lab-sg"
    Project = "cloudops-sre-lab"
  }
}

output "security_group_id" {
  description = "ID of the lab security group"
  value       = aws_security_group.lab.id
}
