locals {
  region     = "us-east-1"
  stage      = "prod"
  account_id = "355738159777"
}

module "artifacts-bucket" {
  source = "../../../services/artifacts-bucket"
  stage  = local.stage
}