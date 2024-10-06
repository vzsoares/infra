variable "stage" {
  type = string
}

resource "aws_s3_bucket" "bucket" {
  bucket = "zenhalab-structured-${var.stage}"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Terraform = "true"
    Stage     = var.stage
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id = "transition_class"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    status = "Enabled"
  }

  rule {
    id = "delete-old-cache"

    filter {
      prefix = "tmp/"
    }

    expiration {
      days = 30
    }

    status = "Enabled"
  }
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.bucket.arn
  description = "The ARN of the S3 bucket"
}
