output "github_action_oidc_workload_identity_pool_id" {
  value = google_iam_workload_identity_pool.github_action_oidc_pool.name
}
