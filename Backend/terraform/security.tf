resource "aws_security_group" "db_sg" {
    name = "db_sg"
    description = "Allow connection only from web server only"
    vpc_id = aws_vpc.Budget_app.id

    ingress{
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_eks_cluster.main.vpc_config[0].cluster_security_group_id]
    }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
}

