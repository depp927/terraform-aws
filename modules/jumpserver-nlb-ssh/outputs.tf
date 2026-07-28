output "nlb_dns_name" {
  value = aws_lb.this.dns_name
}

output "nlb_sg_id" {
  value = aws_security_group.nlb.id
}

output "target_group_arn" {
  value = aws_lb_target_group.ssh.arn
}
