data "aws_acm_certificate" "issued" {
  domain   = "zenhalab.com"
  statuses = ["ISSUED"]
  types    = ["AMAZON_ISSUED"]
}


# S3 bucket for CDN content storage
resource "aws_s3_bucket" "cdn_bucket" {
  bucket = "zenhalab-contents-${var.stage}"

  tags = {
    Stage     = var.stage
    Terraform = "true"
  }
}

# Bucket ACL configuration for CDN access
resource "aws_s3_bucket_ownership_controls" "cdn_bucket_ownership" {
  bucket = aws_s3_bucket.cdn_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "cdn_bucket_access" {
  bucket = aws_s3_bucket.cdn_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "cdn_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.cdn_bucket_ownership,
    aws_s3_bucket_public_access_block.cdn_bucket_access,
  ]

  bucket = aws_s3_bucket.cdn_bucket.id
  acl    = "public-read"
}

# Enable static website hosting
resource "aws_s3_bucket_website_configuration" "cdn_website_config" {
  bucket = aws_s3_bucket.cdn_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# CORS configuration
resource "aws_s3_bucket_cors_configuration" "cdn_cors" {
  bucket = aws_s3_bucket.cdn_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Cache control through bucket policy
resource "aws_s3_bucket_policy" "cdn_bucket_policy" {
  bucket = aws_s3_bucket.cdn_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.cdn_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.cdn_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.cdn_bucket.bucket}"
  }

  enabled             = true
  comment             = "CDN distribution ${var.stage}"
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [
    "cdn.zenhalab.com",
  ]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.cdn_bucket.bucket}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.issued.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Stage     = var.stage
    Terraform = "true"
  }
}
