variable "name" {
  type = string
}
variable "stage" {
  type = string
}

resource "aws_ecrpublic_repository" "ecr_repo" {
  repository_name = "${var.name}-${var.stage}"
  catalog_data {
    about_text        = "CI Runner"
    description       = "Run CI actions, has: python, node, awscli, make, zip"
    operating_systems = ["Linux"]
    usage_text        = "Slap on Pipelines"
  }

  tags = {
    Stage     = var.stage
    Terraform = "true"
  }
}

