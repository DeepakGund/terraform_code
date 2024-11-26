provider "aws" {
  region = "us-west-2"
}

#Terraform_version
terraform {
  required_version = "~> 1.9.0"
}


#AWS_Plugins 
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">5.76.0"
    }
  }
}

locals {
  env = "Terraform"
}

# instance_type
variable "instance_types" {
type = list(string)
default = ["t2.micro", "t2.medium", "t2.small"]
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "${local.env}-VPC"
  }
}

# vpc-subnet
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.10.10.0/24"
  }

# EC2
resource "aws_instance" "ec2" {
  count         = length(var.instance_types)
  subnet_id     = aws_subnet.subnet.id
  ami           = "ami-01b4a58555824692b"
  instance_type = tolist(var.instance_types)[count.index]
  tags = {
    Name = "${local.env}-Server-${count.index + 1}"
  }
}


# Generate RSA private key
resource "tls_private_key" "rsa_key" { 
  algorithm = "RSA"
}

# Save the private key to a local file in PEM format
resource "local_file" "pem_key_file" {
  filename = "rsa_private_key.pem" # File will be created in the current directory
  content  = tls_private_key.rsa_key.private_key_pem 
}

# (Optional) Output the private key for verification (avoid exposing sensitive data)
output "private_key_pem" {
  value     = tls_private_key.rsa_key.private_key_pem 
  sensitive = true
}


output "Public_ips" {
  value = aws_instance.ec2.public_ip
}
