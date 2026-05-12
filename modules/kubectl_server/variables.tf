variable "eks_cluster_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  description = "公有子网 ID 列表，随机选一个部署管理机"
  type        = list(string)
}

variable "eks_cluster_security_group_id" {
  description = "EKS 集群安全组 ID，用于放通 443 访问"
  type        = string
}

variable "eks_cluster_arn" {
  description = "EKS 集群 ARN，用于 access entry 授权"
  type        = string
}

variable "key_name" {
  description = "EC2 密钥对名称"
  type        = string
}