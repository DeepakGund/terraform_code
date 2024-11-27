# Specify AWS provider version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.76.0"
    }
  }
}

# Local environment name
locals {
  env = "Terraform"
}

# Instance types variable
variable "instance_types" {
  type    = list(string)
  default = ["t3.micro", "t3.medium", "t3.small"]
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "${local.env}-VPC"
  }
}

# Subnet
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.10.10.0/24"
  tags = {
    Name = "${local.env}-Subnet"
  }
}

# EC2 Instances
resource "aws_instance" "ec2" {
  count         = length(var.instance_types) # Create instances based on instance_types list
  subnet_id     = aws_subnet.subnet.id
  ami           = "ami-022b9b4e935404526"
  key_name      = "us-west-02" # Updated key pair name
  instance_type = tolist(var.instance_types)[count.index]
  tags = {
    Name = "${local.env}-Server-${count.index + 1}"
  }
}

# Generate RSA private key
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
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
  value = aws_instance.ec2[1].public_ip # Outputs the public IP of the second instance
}
