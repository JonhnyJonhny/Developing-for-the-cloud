terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "main" {
  name = aws_eks_cluster.main.name
  depends_on = [ aws_eks_node_group.workers ]
}

data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
  depends_on = [ aws_eks_node_group.workers ]
}

provider "kubernetes" {
  host = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.main.token
}

provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.main.token
  }
}