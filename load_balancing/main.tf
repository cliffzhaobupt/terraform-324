resource "google_compute_region_network_endpoint_group" "cloudrun_next_app_negs" {
  for_each = toset(var.cloud_run_regions)

  name                  = "cloudrun-next-app-neg-asia-neg-${each.key}"
  network_endpoint_type = "SERVERLESS"
  region                = each.key

  cloud_run {
    service = "cloudrun-next-app-38-${each.key}"
  }
}

module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~>8.0"

  project = "fluid-brook-379710"
  name    = "cloudrun-next-app-load-balancing"

  ssl                             = true
  managed_ssl_certificate_domains = ["web-origin.cliffzhao.com"]
  https_redirect                  = true

  backends = {
    default = {
      description             = null
      protocol                = null
      port_name               = null
      enable_cdn              = false
      custom_request_headers  = null
      custom_response_headers = null
      security_policy         = var.cloud_run_next_app_origin_security_policy_uri
      compression_mode        = null

      log_config = {
        enable      = false
        sample_rate = 1.0
      }

      groups = [
        for neg in google_compute_region_network_endpoint_group.cloudrun_next_app_negs :
        {
          group = neg.id
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }
}
