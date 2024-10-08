terraform {
  backend "s3" {
    #####################################
    # REPLACE THIS with STAGED bucket name!
    #####################################
    bucket = "zenhalab-terraform-iac-prod"
    #####################################
    # REPLACE THIS with UNIQUE key!
    # e.g: {domain}/{project}/terraform.tfstate
    #####################################
    key = "global/ecr/ci-runner/terraform.tfstate"

    region         = "us-east-1"
    dynamodb_table = "terraform-iac-locks-prod"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.59"
    }
  }
  required_version = ">= 1.9.2"
}

provider "aws" {
  region              = local.region
  allowed_account_ids = [local.account_id]
}
