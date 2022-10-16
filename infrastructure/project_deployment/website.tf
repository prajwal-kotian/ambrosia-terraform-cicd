#s3
resource "aws_s3_bucket" "logging_bucket" {
  bucket = replace(format("%s%s", local.project_prefix, "s3log"), "_", "")

  acl           = var.s3_acl_privacy
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = local.tags
}

resource "aws_s3_bucket" "web_assets_bucket" {
  bucket = replace(format("%s%s", local.project_prefix, "s3"), "_", "")

  acl           = var.s3_acl_privacy
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = local.tags
}

resource "aws_s3_bucket_policy" "web_assets_bucket_policy" {
  bucket = aws_s3_bucket.web_assets_bucket.id
  policy = local.s3_policy_source

  depends_on = [
    aws_s3_bucket.web_assets_bucket
  ]
}

resource "null_resource" "upload_to_s3" {
  provisioner "local-exec" {
    command = format("%s%s", "aws s3 sync ./html/ s3://", "${aws_s3_bucket.web_assets_bucket.id}")
  }

  depends_on = [
    aws_s3_bucket.web_assets_bucket, local_file.js
  ]
}

resource "aws_s3_bucket_website_configuration" "s3_web_config" {
  bucket = aws_s3_bucket.web_assets_bucket.bucket

  index_document {
    suffix = var.index_document
  }

  depends_on = [
    null_resource.upload_to_s3
  ]
}

#Cloudfront
resource "aws_cloudfront_origin_access_identity" "origin_access_idenitity" {
  comment = "Ambrosia OAI"
}

resource "aws_cloudfront_distribution" "s3_distribution" {

  origin {
    origin_id = format("%s%s", local.project_prefix, "s3_origin")

    domain_name = aws_s3_bucket.web_assets_bucket.bucket_regional_domain_name
  }

  enabled             = true
  is_ipv6_enabled     = false
  price_class         = var.cdn_price_class["200"]
  web_acl_id          = aws_wafv2_web_acl.cloudfront_web_acl.arn
  comment             = "Ambrosia CDN"
  default_root_object = var.index_document

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logging_bucket.bucket_domain_name
    prefix          = "log"
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = format("%s%s", local.project_prefix, "s3_origin")

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = var.geo_restriction_whitelist
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = local.tags

  depends_on = [
    aws_s3_bucket_website_configuration.s3_web_config, aws_wafv2_web_acl.cloudfront_web_acl
  ]
}
