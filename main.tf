terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.25.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.31.0"
    }
  }
}

resource "aws_s3_bucket" "static_website" {
  bucket = var.dns_name
}

resource "aws_s3_bucket_cors_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  dynamic "cors_rule" {
    for_each = var.cors_rule
    content {
      allowed_headers = cors_rule["allowed_headers"]
      allowed_methods = cors_rule["allowed_methods"]
      allowed_origins = cors_rule["allowed_origins"]
      expose_headers  = cors_rule["expose_headers"]
      max_age_seconds = cors_rule["max_age_seconds"]
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "static_website" {}

data "aws_iam_policy_document" "static_website" {
  statement {
    actions = var.allowed_actions
    resources = [
      aws_s3_bucket.static_website.arn,
      "${aws_s3_bucket.static_website.arn}/*",
    ]
    principals {
      type = "CanonicalUser"
      identifiers = [
        aws_cloudfront_origin_access_identity.static_website.s3_canonical_user_id
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "static_website" {
  bucket = aws_s3_bucket.static_website.id
  policy = data.aws_iam_policy_document.static_website.json
}

resource "aws_acm_certificate" "static_website" {
  domain_name       = var.dns_name
  validation_method = "DNS"
}

resource "aws_cloudfront_distribution" "static_website" {
  aliases = [
    var.dns_name,
  ]
  dynamic "custom_error_response" {
    for_each = var.custom_error_response
    content {
      error_caching_min_ttl = custom_error_response["error_caching_min_ttl"]
      error_code            = custom_error_response["error_code"]
      response_code         = custom_error_response["response_code"]
      response_page_path    = "/${custom_error_response["response_page_path"] == "" ? var.root_object : custom_error_response["response_page_path"]}"
    }
  }
  default_cache_behavior {
    allowed_methods          = var.allowed_methods
    cached_methods           = var.cached_methods
    cache_policy_id          = var.cache_policy_id
    origin_request_policy_id = var.origin_request_policy_id
    target_origin_id         = "${aws_s3_bucket.static_website.id}.s3.${aws_s3_bucket.static_website.region}.amazonaws.com"
    viewer_protocol_policy   = "redirect-to-https"
  }
  default_root_object = var.root_object
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2"
  origin {
    domain_name = "${aws_s3_bucket.static_website.id}.s3.${aws_s3_bucket.static_website.region}.amazonaws.com"
    origin_id   = "${aws_s3_bucket.static_website.id}.s3.${aws_s3_bucket.static_website.region}.amazonaws.com"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static_website.cloudfront_access_identity_path
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.static_website.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}

resource "google_dns_record_set" "s3_cname" {
  name         = var.dns_name
  managed_zone = var.dns_managed_zone
  type         = "CNAME"
  ttl          = 60

  rrdatas = [aws_cloudfront_distribution.static_website.domain_name]
}

resource "google_dns_record_set" "s3_validation" {
  for_each = {
    for domain_validation_option in aws_acm_certificate.static_website.domain_validation_options : domain_validation_option.domain_name => {
      name   = domain_validation_option.resource_record_name
      record = domain_validation_option.resource_record_value
      type   = domain_validation_option.resource_record_type
    }
  }

  name         = each.value.name
  managed_zone = var.dns_managed_zone
  type         = each.value.type
  ttl          = 60

  rrdatas = [each.value.record]
}
