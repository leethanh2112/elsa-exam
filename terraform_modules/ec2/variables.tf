variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead."
  type        = string
  default     = ""
}

variable "hyphen_prefix" {
  type        = string
  description = "Hyphen Prefix for AWS Resource Names"
}

variable "slash_prefix" {
  type        = string
  description = "Slash Prefix for AWS Resource Names (Secrets, Parameters, Key Aliases)"
}

variable "instance_type" {
  type        = string
  description = "instance type of ec2 host"
  default     = "t3.medium"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}

variable "vpc_id" {
  type        = string
  description = "vpc id"
}

variable "kms_key_id" {
  type        = string
  description = "KMS Key ARN to encrypt data"
}

variable "volume_type" {
  type        = string
  description = "EC2 Instance Root Volume Type"
  default     = "gp3"
}

variable "volume_size" {
  type        = number
  description = "EC2 Instance Root Volume Size in GB"
  default     = 16
}
