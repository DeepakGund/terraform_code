  rsa_bits  = 4096  # Specify the key size (e.g., 4096 bits for a strong key)
}

# Save the private key to a local file in PEM format
resource "local_file" "pem_key_file" {
  filename = "deepak.pem"  # File will be created in the current directory with the new name
  content  = tls_private_key.rsa_key.private_key_pem  # Correct resource reference
}

# (Optional) Output the private key for verification (avoid exposing sensitive data)
output "private_key_pem" {
  value     = tls_private_key.rsa_key.private_key_pem  # Correct resource reference
  sensitive = true
}


output "abc" {
  value = aws_instance.ec2[1].public_ip
}

[root@ip-172-31-8-180 git]# vim main.tf

[3]+  Stopped                 vim main.tf
[root@ip-172-31-8-180 git]# ls
deepak.pem  main.tf  terraform.tfstate  terraform.tfstate.backup
[root@ip-172-31-8-180 git]# bash
[root@ip-172-31-8-180 git]# vim main.tf
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
  ami           = "ami-022b9b4e935404526"
  instance_type = tolist(var.instance_types)[count.index]
  tags = {
    Name = "${local.env}-Server-${count.index + 1}"
  }
}

# Generate RSA private key
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096  # Specify the key size (e.g., 4096 bits for a strong key)
}

# Save the private key to a local file in PEM format
resource "local_file" "pem_key_file" {
  filename = "deepak.pem"  # File will be created in the current directory with the new name
  content  = tls_private_key.rsa_key.private_key_pem 
}

# (Optional) Output the private key for verification (avoid exposing sensitive data)
output "private_key_pem" {
  value     = tls_private_key.rsa_key.private_key_pem  
  sensitive = true
}


/*
# Create a new Key Pair in AWS
resource "aws_key_pair" "key-gen" {
  key_name   = "terraform_gen-key"   # Name of the key in AWS
  public_key = tls_public_key.rsa_key.public_key_openssh  # public key
}

key_name      = aws_key_pair.key-gen.key_name 

*/


output "abc" {
  value = aws_instance.ec2[1].public_ip
}

