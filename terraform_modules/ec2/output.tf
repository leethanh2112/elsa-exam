output "secret_arn" {
  value = aws_secretsmanager_secret.key_store.arn
}

output "security_group_id" {
  value = aws_security_group.ec2.id
}

output "primary_network_interface_id" {
  value = aws_instance.ec2.primary_network_interface_id
}

output "instance_id" {
  value = aws_instance.ec2.id
}
