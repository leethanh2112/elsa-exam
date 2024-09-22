locals {
  env        = "prod"
  regionCode = "ue1" ## use-east-1
  name       = "poc"

  resource_name     = "${local.env}-${local.regionCode}-${local.name}"
  alt_resource_name = "${local.env}/${local.regionCode}/${local.name}"


  all_tags = {
    managed-by  = "thanhlcao"
    environment = local.env
    codename    = local.name
  }

  securitygroup = {
    sg_alb = {
      name        = "${local.resource_name}-alb-sg"
      description = "VPC Alb SG"
      cidr_ingress = [
        {
          from_port   = "443"
          to_port     = "443"
          protocol    = "tcp"
          description = "Inbound TCP on port 443"
          cidr_blocks = "0.0.0.0/0"
        },
        {
          from_port   = "80"
          to_port     = "80"
          protocol    = "tcp"
          description = "Inbound TCP on port 80"
          cidr_blocks = "0.0.0.0/0"
        }
      ]
    }
    egress_default = [{
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "All traffic outbound rule"
      cidr_blocks = "0.0.0.0/0"
    }]
    egress_ipv6 = [{
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "All traffic outbound rule"
      cidr_blocks = "::/0"
    }]
  }

  target_group = {
    tg_ingress_nginx = {
      name        = "${local.resource_name}-ingress-nginx-tg"
      port        = "32080"
      protocol    = "HTTP"
      target_type = "ip"
      health_check = {
        interval            = 30
        path                = "/health"
        protocol            = "HTTP"
        timeout             = 5
        healthy_threshold   = 5
        unhealthy_threshold = 2
        matcher             = "200"
      }
    }
  }
}
