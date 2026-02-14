output "instance_ids" {
  value = aws_instance.deployment[*].id
}

output "security_group_id" {
  value = aws_security_group.ec2_security_group.id
}
