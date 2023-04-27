resource "aws_cloudfront_cache_policy" "cloudrun_next_app_default_cache_policy" {
  name    = "cloudrun-next-app-default-cache-policy"
  comment = "default cache policy of cloudrun next app"
  min_ttl = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "whitelist"

      headers {
        items = ["Accept-Language", "Authorization", "RSC", "Next-Router-State-Tree", "Next-Router-Prefetch"]
      }
    }

    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

resource "aws_cloudfront_distribution" "cloudrun_next_app_distribution" {
  comment         = "cloud run next app web distribution"
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = "web-origin.cliffzhao.com"
    origin_id   = "cloud-run-next-app-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = "cloud-run-next-app-origin"
    cache_policy_id        = aws_cloudfront_cache_policy.cloudrun_next_app_default_cache_policy.id
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
