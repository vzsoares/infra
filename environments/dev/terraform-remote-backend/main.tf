locals {
  region     = "us-east-1"
  stage      = "dev"
  account_id = "355738159777"
}

module "terraform-remote-backend" {
  source = "../../../services/terraform-remote-backend"
  stage  = local.stage
}

output "s3_bucket_arn" {
  value = module.terraform-remote-backend.s3_bucket_arn
}
output "dynamodb_table_name" {
  value = module.terraform-remote-backend.dynamodb_table_name
}
