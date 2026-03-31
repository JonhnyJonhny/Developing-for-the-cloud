terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1" 
}

# Automatically fetch the latest Ubuntu 22.04 AMI for this region
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create the EC2 Instance
resource "aws_instance" "budget_app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  # Name your server so it's easy to find in the AWS Console
  tags = {
    Name = "cacto15.com"
  }
}

# Output the public IP address after creation
output "server_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.budget_app_server.public_ip
}