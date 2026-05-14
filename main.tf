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
  public_key = file(var.public_key_path)
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
  depends_on = [module.eks]
}

module "jenkins" {
  source = "./modules/jenkins"   # 根据你的实际路径调整
  vpc_id        = module.vpc.vpc_id
  vpc_cidr      = var.vpc_cidr
  vpc_name      = var.vpc_name
  aws_region    = var.aws_region
  subnet_id     = module.vpc.private_subnet_ids[0]
  subnet_index = "1a"            # 拼出 "my-vpc-private-1a"
  key_name    = aws_key_pair.kubectl_key.key_name

  # ── 可选变量（模块有默认值时可省略）──────────────────
  instance_type   = "t3.medium"
  jenkins_version = "2.452.3"

  tags = {
    Environment = "dev"
    Project     = "my-project"
    ManagedBy   = "terraform"
  }
}

output "kubectl_server_public_ip" {
  value = module.kubectl_server.public_ip
}