variable "aws_region" {
  type    = string
  default = "ap-east-1"
}

variable "vpc_name" {
  type    = string
  default = "smart-eks-vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/19"
}

variable "eks_cluster_name" {
  type    = string
  default = "smart-eks-cluster"
}

variable "eks_cluster_version" {
  type    = string
  default = "1.35"
}

variable "public_key_path" {
  type        = string
  description = "本地公钥文件的路径"
  default     = "~/.ssh/id_rsa.pub"
}