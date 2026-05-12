resource "aws_iam_role" "kubectl_node_role" {
  name = "${var.eks_cluster_name}-kubectl-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "eks_describe" {
  name = "eks-describe-policy"
  role = aws_iam_role.kubectl_node_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["eks:DescribeCluster", "eks:ListClusters"]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "kubectl_profile" {
  name = "${var.eks_cluster_name}-kubectl-profile"
  role = aws_iam_role.kubectl_node_role.name
}

resource "aws_eks_access_entry" "kubectl_admin" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.kubectl_node_role.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "kubectl_admin_policy" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.kubectl_node_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.kubectl_admin]
}