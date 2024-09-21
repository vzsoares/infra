locals {
  region     = "us-east-1"
  stage      = "prod"
  account_id = "355738159777"
}

module "ci-repo" {
  source = "../../../services/ci-runner"
  name   = "zenhalab-ci-runner"
  stage  = local.stage
}

