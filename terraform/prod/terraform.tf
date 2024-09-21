terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }

  required_version = ">= 1.4.0"

  backend "s3" {
    bucket         = "thanhlcao-terraform-state"
    key            = "sandbox/poc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "thanhlcao-terraform-state"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = local.all_tags
  }
}
