resource "aws_db_subnet_group" "main" {
  name = "main-db-subnet-group"
  subnet_ids = [aws_subnet.private_db_1.id,aws_subnet.private_db_2.id]
  tags = { Name = "main-db-subnet-group" }
}

resource "aws_security_group" "rds_sg" {
  name = "rds-security-group"
  description = "Allow MySQL traffic from EKS"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.10.0/24", "10.0.11.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "mysql" {
  identifier = "app-db-mysql"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  db_name = "appdb"
  username = var.db_username
  password = var.db_password
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot = true
  multi_az = false
  storage_encrypted = true
  backup_retention_period = 7
  deletion_protection = true
}