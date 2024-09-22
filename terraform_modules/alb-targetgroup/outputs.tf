output "arn" {
  description = "target group arn"
  value       = aws_lb_target_group.target_group.arn
}

output "id" {
  description = "target group id"
  value       = aws_lb_target_group.target_group.id
}

output "name" {
  description = "target group name"
  value       = aws_lb_target_group.target_group.name
}
