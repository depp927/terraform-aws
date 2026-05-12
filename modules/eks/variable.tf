variable "eks_cluster_name" {
  type = string
}

variable "eks_cluster_version" {
  type = string
}

variable "private_subnet_ids" {
  description = "私有子网 ID 列表，供 EKS vpc_config 使用"
  type        = list(string)
}