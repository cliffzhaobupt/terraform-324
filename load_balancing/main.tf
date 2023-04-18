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

  ssl                             = false
  managed_ssl_certificate_domains = []
  https_redirect                  = false

  backends = {
    default = {
      description             = null
      protocol                = null
      port_name               = null
      enable_cdn              = false
      custom_request_headers  = null
      custom_response_headers = null
      security_policy         = null
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
