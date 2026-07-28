variable "name" {
  description = "Jumpserver instance name"
  type        = string
  default     = "jumpserver"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Private subnet ID for jumpserver"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
