resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.hyphen_prefix}-instance-profile"
  role = aws_iam_role.ssm_role.name
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical's owner ID for Ubuntu AMIs
}

resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  # checkov:skip=CKV_AWS_88: "EC2 instance should not have public IP. - It is required to have a public IP"
  associate_public_ip_address = true
  ebs_optimized               = true
  monitoring                  = true
  user_data                   = var.user_data

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  root_block_device {
    encrypted   = true
    kms_key_id  = var.kms_key_id
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  tags = {
    Name = "${var.hyphen_prefix}-ec2"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}
