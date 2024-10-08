###### Variables ######
variable "stage" {
  type = string
}

#######################
###### Resources ######
#######################

###### DynamoDB ######
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-iac-locks-${var.stage}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Terraform = "true"
    Stage     = var.stage
  }
}

###### S3 ######
resource "aws_s3_bucket" "terraform_state" {
  bucket = "zenhalab-terraform-iac-${var.stage}"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Terraform = "true"
    Stage     = var.stage
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  depends_on = [aws_s3_bucket_versioning.enabled]

  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id = "expire-versions"

    noncurrent_version_expiration {
      newer_noncurrent_versions = 3
      noncurrent_days           = 90
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }

    status = "Enabled"
  }
}

###### OUTPUTS ######
output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}
