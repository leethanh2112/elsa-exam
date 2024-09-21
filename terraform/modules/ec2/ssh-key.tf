resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "this" {
  key_name   = "${var.hyphen_prefix}-ec2-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_secretsmanager_secret" "key_store" {
  name        = "${var.slash_prefix}/ec2/scrt"
  description = "ec2 Private SSH Key"
  kms_key_id  = var.kms_key_id
  #checkov:skip=CKV2_AWS_57: "Ensure Secrets Manager secrets should have automatic rotation enabled"
}

resource "aws_secretsmanager_secret_version" "key_store_version" {
  secret_id     = aws_secretsmanager_secret.key_store.id
  secret_string = tls_private_key.this.private_key_pem
}
