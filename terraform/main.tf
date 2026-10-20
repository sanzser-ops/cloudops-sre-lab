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

  lifecycle {
    ignore_changes = [ingress]
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

resource "aws_vpc_security_group_ingress_rule" "ssh_my_ip" {
  security_group_id = aws_security_group.lab.id
  cidr_ipv4         = "113.203.182.254/32"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "SSH from my public IP only"
}

resource "aws_vpc_security_group_ingress_rule" "ssh_ec2_instance_connect" {
  security_group_id = aws_security_group.lab.id
  prefix_list_id    = "pl-0839cc4c195a4e751"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_key_pair" "lab" {
  key_name   = "cloudops-sre-lab-key"
  public_key = file(pathexpand("~/.ssh/cloudops-sre-lab-aws.pub"))

  tags = {
    Name    = "cloudops-sre-lab-key"
    Project = "cloudops-sre-lab"
  }
}

output "key_pair_name" {
  description = "Name of the SSH key pair"
  value       = aws_key_pair.lab.key_name
}
resource "aws_instance" "lab" {
  ami                         = "ami-051ef443317b2de18"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.lab.id]
  key_name                    = aws_key_pair.lab.key_name
  associate_public_ip_address = true

  tags = {
    Name        = "cloudops-sre-lab-ec2"
    Project     = "cloudops-sre-lab"
    Environment = "lab"
  }
}

output "instance_id" {
  description = "ID of the lab EC2 instance"
  value       = aws_instance.lab.id
}

output "instance_public_ip" {
  description = "Public IP of the lab EC2 instance"
  value       = aws_instance.lab.public_ip
}
