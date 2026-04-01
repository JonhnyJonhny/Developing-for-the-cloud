variable "aws_region" {
  description = "Resource deployment location"
  type = string
  default = "us-east-1"
}

variable "db_password" {
    description = "DB master password"
    type = string
    sensitive = true
    default = "admin123"
}

variable "db_username" {
  description = "DB master username"
  type = string
  default = "admin"
}

variable "instance_type" {
  description = "Web Server Size"
  type = string
  default = "t3.micro"
}