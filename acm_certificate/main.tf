resource "aws_acm_certificate" "cloud_run_next_app_distribution_acm_certificate" {
  domain_name       = "cloudrun-next-app-clouddns-to-cloudfront.cliffzhao.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
