
module "vpc" {
  source = "./modules/vpc"

  vpc_name         = var.vpc_name
  vpc_cidr         = var.vpc_cidr
  eks_cluster_name = var.eks_cluster_name
}

module "eks" {
  source = "./modules/eks"

  eks_cluster_name    = var.eks_cluster_name
  eks_cluster_version = var.eks_cluster_version
  private_subnet_ids  = module.vpc.private_subnet_ids
}

resource "aws_key_pair" "kubectl_key" {
  key_name   = "kubectl-server-key"
  public_key = var.public_key # 确保在 variables.tf 中定义了此变量
}

module "kubectl_server" {
  source = "./modules/kubectl_server"

  eks_cluster_name              = var.eks_cluster_name
  aws_region                    = var.aws_region
  vpc_id                        = module.vpc.vpc_id
  public_subnet_ids             = module.vpc.public_subnet_ids
  eks_cluster_security_group_id = module.eks.cluster_security_group_id
  eks_cluster_arn               = module.eks.cluster_arn
  key_name                      = aws_key_pair.kubectl_key.key_name
}

output "kubectl_server_public_ip" {
  value = module.kubectl_server.public_ip
}