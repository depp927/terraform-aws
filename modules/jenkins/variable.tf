# 来自根模块传入的
variable "vpc_name" {
  type = string
}

variable "aws_region" {
  type = string
}

# Jenkins module 自身特有的
variable "subnet_index" {
  type    = number
  default = 1
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}
