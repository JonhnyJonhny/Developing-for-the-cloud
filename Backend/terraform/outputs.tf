output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = aws_eks_cluster.main.endpoint
}

output "rds_endpoint" {
  description = "Connection endpoint for the RDS MySQL database"
  value       = aws_db_instance.mysql.endpoint
}

output "rds_port" {
  description = "Port for the RDS MySQL database"
  value       = aws_db_instance.mysql.port
}