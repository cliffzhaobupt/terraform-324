provider "google" {
  project = "fluid-brook-379710"
  region  = "asia-east1"
  zone    = "asia-east1-b"
}

module "service_account" {
  source = "./service_account"
}
