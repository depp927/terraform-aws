variable "nlb_name" {
  description = "Public NLB name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the NLB"
  type        = list(string)
}

variable "target_id" {
  description = "JumpServer instance ID"
  type        = string
}

variable "target_port" {
  description = "JumpServer SSH port"
  type        = number
  default     = 22
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
