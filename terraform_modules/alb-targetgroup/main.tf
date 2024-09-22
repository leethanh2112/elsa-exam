resource "aws_lb_target_group" "target_group" {
  name        = var.name
  port        = var.port
  protocol    = var.protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id
  health_check {
    interval            = var.health_check.interval
    path                = var.health_check.path
    protocol            = var.health_check.protocol
    timeout             = var.health_check.timeout
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
    matcher             = var.health_check.matcher
  }
  tags = var.tags
}
