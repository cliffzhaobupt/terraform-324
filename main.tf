terraform {
  required_version = ">= 1.4.5"
}

provider "google" {
  project = "fluid-brook-379710"
  region  = "asia-east1"
  zone    = "asia-east1-b"
}

module "workload_identity" {
  source = "./workload_identity"
}

module "service_account" {
  source                                       = "./service_account"
  github_action_oidc_workload_identity_pool_id = module.workload_identity.github_action_oidc_workload_identity_pool_id
}

module "load_balancing" {
  source            = "./load_balancing"
  cloud_run_regions = ["asia-northeast1", "us-west1"]
}
