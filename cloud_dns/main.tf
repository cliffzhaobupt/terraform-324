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
