locals {
  region     = "us-east-1"
  stage      = "prod"
  account_id = "355738159777"
}

module "api-custom-domains" {
  source = "../../../services/api-custom-domains"
  stage  = local.stage
}
