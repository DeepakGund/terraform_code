terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.76.0"
    }
  }
}

locals {
  env = "DEV-SEC-OPS"
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.micro", "t3.medium", "t3.small"]
}

# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${local.env}-VPC"
  }
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = {
    Name = "${local.env}-Public-Subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Internet-Gateway"
  }
}

# Create Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Public-Route-Table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Add Route to Internet Gateway in Route Table
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Create Security Group
resource "aws_security_group" "allow_all_sg" {
  vpc_id = aws_vpc.vpc.id
  name   = "Allow-All-Traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow-All-Traffic"
  }
}

# EC2 Instances
resource "aws_instance" "ec2" {
  count         = length(var.instance_types)
  subnet_id     = aws_subnet.public_subnet.id
  ami           = "ami-022b9b4e935404526" # Update AMI as needed
  key_name      = "us-west-02"
  instance_type = var.instance_types[count.index]
  tags = {
    Name = "${local.env}-Server-${count.index + 1}"
  }
/*
  # Configure SSH access and install packages
  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip # Use the instance's public IP
    private_key = file("~/.ssh/devops.pem")
  }
*/
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install git tree -y",
      "touch remote-exec.txt"
    ]
  }
}

# Generate RSA private key
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
}

# Save RSA private key locally
resource "local_file" "pem_key_file" {
  filename = "deepak.pem"
  content  = tls_private_key.rsa_key.private_key_pem
}

# Outputs
output "private_key_pem" {
  value     = tls_private_key.rsa_key.private_key_pem
  sensitive = true
}

output "public_ip_second_instance" {
  value = aws_instance.ec2[1].public_ip
}
