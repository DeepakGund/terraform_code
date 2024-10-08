provider "aws" {
  region = "us-west-2"
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


output "abc" {
  value = aws_instance.ec2
}
