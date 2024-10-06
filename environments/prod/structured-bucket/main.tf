locals {
  region     = "us-east-1"
  stage      = "prod"
  account_id = "355738159777"
}

module "structured-bucket" {
  source = "../../../services/structured-bucket"
  stage  = local.stage
}
