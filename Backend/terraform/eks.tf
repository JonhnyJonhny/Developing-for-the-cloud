resource "aws_eks_cluster" "main" {
  name = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn
  version = "1.30"

  vpc_config {
    subnet_ids = [aws_subnet.private_1.id,aws_subnet.private_2.id]
    endpoint_private_access = true
    endpoint_public_access = true
  }

  depends_on = [ aws_iam_policy_attachment.cluster_policy ]
}

resource "aws_eks_node_group" "app_nodes" {
  cluster_name = aws_eks_cluster.main.name
  node_group_name = "app_nodes"
  node_role_arn = aws_iam_role.node_role.arn
  subnet_ids = [aws_subnet.private_1.id,aws_subnet.private_2.id]
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size = 4
    min_size = 2
  }

  tags = {
    "k8s.io/cluster-autoscaler/enabled"                    = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}"        = "owned"
  }

  depends_on = [ 
    aws_iam_role_policy_attachment.node_policy,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.eks_ecr,
    aws_iam_role_policy_attachment.cluster_autoscaler,
   ]
}