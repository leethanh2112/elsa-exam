################################################################################
# VPC & Subnets
################################################################################
resource "aws_vpc" "this" {
  cidr_block           = "10.124.204.0/22"
  enable_dns_hostnames = true
  #checkov:skip=CKV2_AWS_11: "Ensure VPC flow logging is enabled in all VPCs"
  #checkov:skip=CKV2_AWS_12: "Ensure the default security group of every VPC restricts all traffic"
  tags = {
    Name = "${local.resource_name}-vpc"
    Tier = "network"
  }
}

resource "aws_subnet" "public-subnet1a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.124.204.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "${local.resource_name}-public-subnet1a"
    Tier = "network"
  }
}

resource "aws_subnet" "public-subnet1b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.124.205.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "${local.resource_name}-public-subnet1b"
    Tier = "network"
  }
}

resource "aws_subnet" "app-private-subnet1a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.124.206.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "${local.resource_name}-app-private-subnet1a"
    Tier = "network"
  }
}

resource "aws_subnet" "app-private-subnet1b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.124.207.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "${local.resource_name}-app-private-subnet1b"
    Tier = "network"
  }
}

### Internet Gateway ####
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.resource_name}-igw"
    Tier = "network"
  }
}

### NAT Gateway ####
resource "aws_eip" "this" {
  tags = {
    "Name" = "${local.resource_name}-eip"
  }
}

resource "aws_nat_gateway" "this" {
  subnet_id     = aws_subnet.public-subnet1a.id
  allocation_id = aws_eip.this.id
  depends_on = [
    aws_internet_gateway.this
  ]
  tags = {
    Name = "${local.resource_name}-natgw"
    Tier = "network"
  }
}

### Route Table ###
resource "aws_route_table" "public-rtb1a" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  route {
    cidr_block = aws_vpc.this.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "${local.resource_name}-subnet1a-rtb1"
    Tier = "network"
  }
}

resource "aws_route_table_association" "public-rtb1a-association" {
  subnet_id      = aws_subnet.public-subnet1a.id
  route_table_id = aws_route_table.public-rtb1a.id
}

resource "aws_route_table" "public-rtb1b" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  route {
    cidr_block = aws_vpc.this.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "${local.resource_name}-subnet1b-rtb1"
    Tier = "network"
  }
}

resource "aws_route_table_association" "public-rtb1b-association" {
  subnet_id      = aws_subnet.public-subnet1b.id
  route_table_id = aws_route_table.public-rtb1b.id
}

resource "aws_route_table" "app-private-rtb1a" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  route {
    cidr_block = aws_vpc.this.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "${local.resource_name}-subnet1a-rtb1"
    Tier = "network"
  }
}

resource "aws_route_table_association" "private-rtb1a-association" {
  subnet_id      = aws_subnet.app-private-subnet1a.id
  route_table_id = aws_route_table.app-private-rtb1a.id
}

resource "aws_route_table" "app-private-rtb1b" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  route {
    cidr_block = aws_vpc.this.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "${local.resource_name}-subnet1b-rtb1"
    Tier = "network"
  }
}

resource "aws_route_table_association" "private-rtb1b-association" {
  subnet_id      = aws_subnet.app-private-subnet1b.id
  route_table_id = aws_route_table.app-private-rtb1b.id
}

################################################################################
# KMS
################################################################################
resource "aws_kms_key" "this" {
  description             = "KMS Key used to encrypt this related resources"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms.json
}

resource "aws_kms_alias" "integration" {
  name          = "alias/${local.alt_resource_name}-kms"
  target_key_id = aws_kms_key.this.id
}

#################################################################################
# EC2 Instance
#################################################################################
module "ec2" {
  source = "././terraform_modules/ec2"

  hyphen_prefix = local.resource_name
  slash_prefix  = local.alt_resource_name

  vpc_id    = aws_vpc.this.id
  subnet_id = aws_subnet.public-subnet1a.id

  kms_key_id = aws_kms_key.this.arn

  instance_type = "t3.medium"
  volume_size   = 32

  user_data = filebase64("./user-data/setup.sh")

  # checkov:skip=CKV2_AWS_57: "Ensure Secrets Manager secrets should have automatic rotation enabled - We don't have a way to rotate ec2 private key for now"
}

################################################################################
# Hosted Zone & Records
################################################################################
resource "aws_route53_record" "this" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "${local.env}.elsa.com"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.this.name_servers
}

resource "aws_route53_zone" "this" {
  name = "${local.env}.elsa.com"
  #checkov:skip=CKV2_AWS_39
  #checkov:skip=CKV2_AWS_38
}

################################################################################
# ACM Module
################################################################################
module "acm_ingress_nginx" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "${local.env}.elsa.com"
  zone_id     = aws_route53_zone.this.zone_id

  subject_alternative_names = [
    "*.${local.env}.elsa.com",
  ]

  validate_certificate = true

  tags = {
    Name = "${local.env}.elsa.com"
  }
}

#################################################################################
# Security Groups
#################################################################################
module "sg_alb" {
  source      = "././terraform_modules/securitygroup"
  name        = local.securitygroup.sg_alb.name
  description = local.securitygroup.sg_alb.description
  vpc_id      = aws_vpc.this.id
  ingress_with_cidr_blocks = concat(
    local.securitygroup.sg_alb.cidr_ingress
  )
  egress_with_cidr_blocks      = local.securitygroup.egress_default
  egress_with_ipv6_cidr_blocks = local.securitygroup.egress_ipv6
}

#################################################################################
# Application loadbalance
#################################################################################
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name                   = "${local.resource_name}-alb"
  load_balancer_type     = "application"
  vpc_id                 = module.vpc.vpc_id
  subnets                = [aws_subnet.public-subnet1a.id, aws_subnet.public-subnet1b.id]
  security_groups        = [module.sg_alb.this_security_group_id]
  create_security_group  = false
  enable_xff_client_port = false

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  https_listeners = [
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm_ingress_nginx.acm_certificate_arn
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Not Found"
        status_code  = "404"
      }
    }
  ]

  # checkov:skip=CKV_AWS_91: "Ensure the ELBv2 (Application/Network) has access logging enabled"
  # https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-logging-policies/bc-aws-logging-22

  # checkov:skip=CKV_AWS_150: "Ensure that Load Balancer has deletion protection enabled"
  # https://docs.bridgecrew.io/docs/bc_aws_networking_62

  # checkov:skip=CKV_AWS_131: "Ensure that ALB drops HTTP headers"
  # https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-that-alb-drops-http-headers

  # checkov:skip=CKV2_AWS_28: "Ensure public facing ALB are protected by WAF"
  # https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-public-facing-alb-are-protected-by-waf

  # checkov:skip=CKV_AWS_152: "Ensure that Load Balancer (Network/Gateway) has cross-zone load balancing enabled"
}

# ################################################################################
# # ELB Target Group
# ################################################################################
module "tg_ingress_nginx" {
  source       = "././terraform_modules/alb-targetgroup"
  name         = local.target_group.tg_ingress_nginx.name
  port         = local.target_group.tg_ingress_nginx.port
  protocol     = local.target_group.tg_ingress_nginx.protocol
  target_type  = local.target_group.tg_ingress_nginx.target_type
  health_check = local.target_group.tg_ingress_nginx.health_check
  vpc_id       = aws_vpc.this.id
}

# ################################################################################
# # ELB Listener Rules
# ################################################################################
module "alb_rule_intergy" {
  source            = "././terraform_modules/alb-listen-rules"
  listener_arn      = module.alb.https_listener_arns[0]
  priority          = 100
  module_depends_on = module.tg_ingress_nginx
  action = {
    type             = "forward"
    target_group_arn = module.tg_ingress_nginx.arn
  }
  conditions = {
    intergy_condition = {
      host_header = {
        values = ["*.${local.env}.elsa.com"]
      }
    }
  }
}
