resource "google_iam_workload_identity_pool" "github_action_oidc_pool" {
  workload_identity_pool_id = "github-action-oidc-pool"
  display_name              = "Github action oidc pool"
  description               = "Github action pool for executing Cloud Run deploy"
}

resource "google_iam_workload_identity_pool_provider" "github_action_oidc_pool_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_action_oidc_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-action-oidc-pool-provider"
  display_name                       = "Github action oidc pool provider"
  description                        = "Github action pool provider for executing Cloud Run deploy"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
