data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]

    filter {
      name = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
    filter {
      name = "virtualization-type"
      values = [ "hvm" ]
    }
}

resource "aws_instance" "web_server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.public_subnet1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "BudgetTracker-webservers"
  }
}

output "server_public_ip" {
  description = "public IP"
  value = aws_instance.web_server.public_ip
}

