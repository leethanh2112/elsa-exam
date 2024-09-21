################################################################################
# VPC & Subnets
################################################################################
resource "aws_vpc" "this" {
  cidr_block           = "10.124.208.0/22"
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
  cidr_block        = "10.124.208.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "${local.resource_name}-public-subnet1a"
    Tier = "network"
  }
}

resource "aws_subnet" "public-subnet1b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.124.209.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "${local.resource_name}-public-subnet1b"
    Tier = "network"
  }
}

resource "aws_subnet" "app-private-subnet1a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.124.210.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "${local.resource_name}-app-private-subnet1a"
    Tier = "network"
  }
}

resource "aws_subnet" "app-private-subnet1b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.124.211.0/24"
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
  source = "./modules/ec2"

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
