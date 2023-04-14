resource "google_service_account" "cloudrun_deploy_bot" {
  account_id   = "cloudrun-deploy-bot"
  display_name = "Cloud Run deploy bot Service Account"
}

resource "google_project_iam_member" "cloudrun_deploy_bot_run_admin" {
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.cloudrun_deploy_bot.email}"
  project = "fluid-brook-379710"
}

resource "google_project_iam_member" "cloudrun_deploy_bot_editor" {
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.cloudrun_deploy_bot.email}"
  project = "fluid-brook-379710"
}

resource "google_project_iam_member" "cloudrun_deploy_bot_sa_user" {
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloudrun_deploy_bot.email}"
  project = "fluid-brook-379710"
}

resource "google_project_iam_member" "cloudrun_deploy_bot_storage_admin" {
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.cloudrun_deploy_bot.email}"
  project = "fluid-brook-379710"
}

resource "google_service_account_iam_member" "github_action_oidc_pool_iam_member" {
  service_account_id = google_service_account.cloudrun_deploy_bot.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${var.github_action_oidc_workload_identity_pool_id}/attribute.repository/${local.repository_name}"
}
