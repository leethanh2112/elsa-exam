variable "name" {
  description = "Name of the target group"
  type        = string
}
variable "port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 80
}

variable "tags" {
  description = "Map of resource tags for the IAM Policy"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "Identifier of the VPC in which to create the target group"
  type        = string
}

variable "protocol" {
  description = "Protocol to use for routing traffic to the targets"
  type        = string
}

variable "target_type" {
  description = "Type of target that you must specify when registering targets with this target group"
  type        = string
}

variable "health_check" {
  description = "Health Check configuration block"
  type        = map(string)
  default = {
    interval            = 30
    path                = "/health"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-499"
  }
}