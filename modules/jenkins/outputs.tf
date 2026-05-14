output "instance_id" {
  description = "Jenkins EC2 实例 ID"
  value       = aws_instance.jenkins.id
}

output "private_ip" {
  description = "Jenkins 实例私网 IP"
  value       = aws_instance.jenkins.private_ip
}

output "security_group_id" {
  description = "Jenkins Security Group ID"
  value       = aws_security_group.jenkins.id
}

output "subnet_id" {
  description = "Jenkins 实际部署的子网 ID"
  value       = var.subnet_id
}

output "iam_role_arn" {
  description = "Jenkins IAM Role ARN"
  value       = aws_iam_role.jenkins.arn
}

