variable "stage" {
  type = string
}

data "aws_acm_certificate" "issued" {
  domain   = "zenhalab.com"
  statuses = ["ISSUED"]
  types = ["AMAZON_ISSUED"]
}

resource "aws_apigatewayv2_domain_name" "api" {
  domain_name = "api${var.stage == "dev" ? "-dev" : ""}.zenhalab.com"

  domain_name_configuration {
    certificate_arn = data.aws_acm_certificate.issued.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = {
    Terraform = "true"
    Stage     = var.stage
  }
}
