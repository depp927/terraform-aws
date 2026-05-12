output "public_ip" {
  description = "管理服务器的公网 IP"
  value       = aws_instance.kubectl_server.public_ip
}

output "instance_id" {
  value = aws_instance.kubectl_server.id
}

output "security_group_id" {
  value = aws_security_group.kubectl_sg.id
}