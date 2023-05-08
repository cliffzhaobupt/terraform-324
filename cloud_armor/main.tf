resource "google_compute_security_policy" "cloudrun_next_app_origin_security_policy" {
  name = "cloudrun-next-app-origin-security-policy"

  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default rule"
  }

  rule {
    action   = "allow"
    priority = "1000"
    match {
      expr {
        expression = "has(request.headers['${var.cloudrun_next_app_secret_header_name}']) && request.headers['${var.cloudrun_next_app_secret_header_name}'] == '${var.cloudrun_next_app_secret_header_value}'"
      }
    }
    description = "Must have secret-header header set in Cloud Front"
  }
}
