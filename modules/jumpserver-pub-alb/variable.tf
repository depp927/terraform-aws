variable "alb_name" {
  description = "Public ALB name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

variable "target_id" {
  description = "JumpServer instance ID"
  type        = string
}

variable "target_port" {
  description = "JumpServer web port"
  type        = number
  default     = 80
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
