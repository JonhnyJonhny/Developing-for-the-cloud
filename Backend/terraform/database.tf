resource "aws_db_subnet_group" "db_subnet" {
  name = "db_subnet_group"
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
}

resource "aws_db_instance" "Budget_app_db" {
  allocated_storage = "20"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  db_name = "Budget_app_db_instance"
  username = var.db_username
  password = var.db_password
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az = false
}

output "db_endpoint" {
  value = aws_db_instance.Budget_app_db.endpoint
}