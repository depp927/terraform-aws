variable "name" {
  description = "EC2 instance name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Private subnet ID"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "jumpserver_security_group_id" {
  description = "Jumpserver security group ID allowed to SSH to this instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m7i.xlarge"

  validation {
    condition     = contains(["m7i.xlarge", "m7a.xlarge"], var.instance_type)
    error_message = "instance_type 只能是 m7i.xlarge 或 m7a.xlarge。"
  }
}

variable "data_device_name" {
  description = "Additional data disk device name"
  type        = string
  default     = "/dev/sdf"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
