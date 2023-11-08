locals {
  project_id               = "<< YOUR PROJECT ID >>"
  region                   = "asia-northeast1"
  circleci_organization_id = "<< YOUR CIRCLECI ORGANIZATION ID >>"
  circleci_project_id      = "<< YOUR CIRCLECI PROJECT ID >>"
  account_id               = "<< SERVICE ACCOUNT ID>>"
}

resource "google_iam_workload_identity_pool" "circleci" {
  provider = google-beta
  project  = local.project_id

  workload_identity_pool_id = "circleci"
}

resource "google_iam_workload_identity_pool_provider" "circleci" {
  provider = google-beta
  project  = local.project_id

  workload_identity_pool_id          = google_iam_workload_identity_pool.circleci.workload_identity_pool_id
  workload_identity_pool_provider_id = "circleci-prvdr"

  attribute_mapping = {
    "attribute.aud"        = "assertion.aud"
    "attribute.iss"        = "assertion.iss"
    "attribute.project_id" = "assertion['oidc.circleci.com/project-id']"
    "google.subject"       = "assertion.sub"
  }

  oidc {
    allowed_audiences = [local.circleci_organization_id]
    issuer_uri        = "https://oidc.circleci.com/org/${local.circleci_organization_id}"
  }
}

resource "google_service_account" "sa" {
  project = local.project_id

  account_id = local.account_id
}

resource "google_service_account_iam_member" "wif-sa" {
  service_account_id = google_service_account.sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.circleci.name}/attribute.project_id/${local.circleci_project_id}"
}

resource "google_project_iam_member" "project" {
  project = local.project_id

  role   = "roles/editor"
  member = "serviceAccount:${google_service_account.sa.email}"
}
