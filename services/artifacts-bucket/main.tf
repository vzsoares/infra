variable "stage" {
  type = string
}

resource "aws_s3_bucket" "bucket" {
  bucket = "zenhalab-artifacts-${var.stage}"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Terraform = "true"
    Stage     = var.stage
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "expire-old-versions" {
  depends_on = [aws_s3_bucket_versioning.enabled]

  bucket = aws_s3_bucket.bucket.id

  rule {
    id = "expire-versions"

    noncurrent_version_expiration {
      newer_noncurrent_versions = 4
      noncurrent_days = 90
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

output "s3_bucket_arn" {
  value       = aws_s3_bucket.bucket.arn
    description = "The ARN of the S3 bucket"
}
