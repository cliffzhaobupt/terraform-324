resource "google_dns_managed_zone" "cliffzhao_com_dns_zone" {
  name        = "cliffzhao-com"
  dns_name    = "cliffzhao.com."
  description = "DNS zone of cliffzhao.com"
}

resource "google_dns_record_set" "lb_origin_dns_record" {
  name         = "web-origin.${google_dns_managed_zone.cliffzhao_com_dns_zone.dns_name}"
  managed_zone = google_dns_managed_zone.cliffzhao_com_dns_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.lb_external_ip]
}

resource "google_dns_record_set" "cloud_run_next_app_distribution_acm_certificate_validation_dns_record" {
  name         = var.cloud_run_next_app_distribution_acm_certificate_dns_record_name
  managed_zone = google_dns_managed_zone.cliffzhao_com_dns_zone.name
  type         = var.cloud_run_next_app_distribution_acm_certificate_dns_record_type
  ttl          = 300
  rrdatas      = [var.cloud_run_next_app_distribution_acm_certificate_dns_record_value]
}

resource "google_dns_record_set" "cloud_run_next_app_cloudfront_distribution_dns_record" {
  name         = "cloudrun-next-app-clouddns-to-cloudfront.${google_dns_managed_zone.cliffzhao_com_dns_zone.dns_name}"
  managed_zone = google_dns_managed_zone.cliffzhao_com_dns_zone.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["${var.cloud_run_next_app_cloudfront_distribution_domain_name}."]
}
