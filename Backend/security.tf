resource "aws_security_group" "web_sg" {
  name = "web_sg"
  description = "Allow HTTP,HTTPS,SSH"
  vpc_id = aws_vpc.Budget_app.id

  #HTTP
  ingress{
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #HTTPS
  ingress{
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #SSH
  ingress{
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #allow outbound traffics
  egress{
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
    name = "db_sg"
    description = "Allow connection only from web server only"
    vpc_id = aws_vpc.Budget_app.id

    ingress{
        from_port = "3306"
        to_port = "3306"
        protocol = "tcp"
        security_groups = [aws_security_group.web_sg.id]
    }
  
}

