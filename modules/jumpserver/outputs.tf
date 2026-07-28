output "instance_id" {
  value = aws_instance.jumpserver.id
}

output "private_ip" {
  value = aws_instance.jumpserver.private_ip
}

output "security_group_id" {
  value = aws_security_group.jumpserver.id
}
