# 来自根模块传入的
variable "vpc_name" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
  }

# Jenkins module 自身特有的
variable "subnet_index" {
  type    = string
  default = "1"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

# 
variable "key_name" {
  description = "EC2 Key Pair 名称"
  type        = string
}

variable "jenkins_version" {
  description = "Jenkins 版本号"
  type        = string
  default     = "2.452.3"
}

variable "tags" {
  description = "附加到所有资源的公共标签"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "Jenkins 所在私有子网 ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR，用于 SSH 入站规则"
  type        = string
}