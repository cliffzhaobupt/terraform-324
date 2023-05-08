terraform {
  required_version = ">= 1.4.5"
}

provider "google" {
  project = "fluid-brook-379710"
  region  = "asia-east1"
  zone    = "asia-east1-b"
}

provider "aws" {
  region = "us-east-1"
}

module "workload_identity" {
  source = "./workload_identity"
}

module "service_account" {
  source                                       = "./service_account"
  github_action_oidc_workload_identity_pool_id = module.workload_identity.github_action_oidc_workload_identity_pool_id
}

module "cloud_armor" {
  source                                = "./cloud_armor"
  cloudrun_next_app_secret_header_name  = "secret-header"
  cloudrun_next_app_secret_header_value = "cf38ac0b4194"
}

module "load_balancing" {
  source                                        = "./load_balancing"
  cloud_run_regions                             = ["asia-northeast1", "us-west1"]
  cloud_run_next_app_origin_security_policy_uri = module.cloud_armor.cloud_run_next_app_origin_security_policy_uri
}

module "acm_certificate" {
  source = "./acm_certificate"
}

module "cloud_dns" {
  source                                                           = "./cloud_dns"
  lb_external_ip                                                   = module.load_balancing.lb_external_ip
  cloud_run_next_app_cloudfront_distribution_domain_name           = module.cloud_front.cloud_run_next_app_cloudfront_distribution_domain_name
  cloud_run_next_app_distribution_acm_certificate_dns_record_name  = module.acm_certificate.cloud_run_next_app_distribution_acm_certificate_dns_record_name
  cloud_run_next_app_distribution_acm_certificate_dns_record_type  = module.acm_certificate.cloud_run_next_app_distribution_acm_certificate_dns_record_type
  cloud_run_next_app_distribution_acm_certificate_dns_record_value = module.acm_certificate.cloud_run_next_app_distribution_acm_certificate_dns_record_value
}

module "lambda_edge" {
  source = "./lambda@edge"
}

module "cloud_front" {
  source                                           = "./cloud_front"
  cloudrun_next_app_acm_certificate_arn            = module.acm_certificate.cloud_run_next_app_distribution_acm_certificate_arn
  cloudrun_next_app_viewer_request_lambda_edge_arn = module.lambda_edge.viewer_request_lambda_edge_arn
  cloudrun_next_app_secret_header_name             = "secret-header"
  cloudrun_next_app_secret_header_value            = "cf38ac0b4194"
}
