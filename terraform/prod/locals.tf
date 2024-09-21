locals {
  env        = "prod"
  regionCode = "ue1"
  name       = "poc"
  region     = "us-east-1"

  resource_name     = "${local.env}-${local.regionCode}-${local.name}"
  alt_resource_name = "${local.env}/${local.regionCode}/${local.name}"


  all_tags = {
    managed-by  = "thanhlcao"
    environment = local.env
    codename    = local.name
  }

}