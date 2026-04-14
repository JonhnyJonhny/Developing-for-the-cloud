variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "budget-app-cluster"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  default     = "admin" #can also be change
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
  default     = "admin123!" #can change to the admin liking, must be at least 8 char
}