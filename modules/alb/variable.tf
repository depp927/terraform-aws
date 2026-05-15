variable "alb_name" {
  type        = string
  description = "ALB 的名称"
}

variable "vpc_id" {
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "ALB 所在的子网（公有或私有）"
}

variable "is_internal" {
  type        = bool
  default     = false
  description = "是否为内网负载均衡器"
}

variable "target_id" {
  type        = string
  description = "后端实例 ID (如 Jenkins EC2 ID)"
}

variable "target_port" {
  type        = number
  default     = 8080
}

variable "tags" {
  type    = map(string)
  default = {}
}