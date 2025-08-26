resource "google_iam_workload_identity_pool" "github_pool" {
  provider = google
  project  = var.project
  workload_identity_pool_id = var.pool_id
  display_name = "GitHub Actions Pool"
  description  = "Pool for GitHub Actions OIDC federation - only for ${var.github_owner}/${var.github_repo}"
}

resource "google_iam_workload_identity_pool_provider" "provider" {
  provider = google
  workload_identity_pool_id = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name = "GitHub Actions Provider"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
  # Restrict tokens to only the configured repository (mapped to attribute.repository)
  attribute_condition = "attribute.repository == \"${var.github_owner}/${var.github_repo}\""
}

resource "google_service_account" "github_actions_sa" {
  account_id   = var.sa_account_id
  display_name = "GitHub Actions Service Account"
  project      = var.project
}

# Grant Owner role on the project to the SA (per user request). This is broad - review later for least privilege.
resource "google_project_iam_member" "sa_owner" {
  project = var.project
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Allow identities from the Workload Identity Pool filtered to the specific repository to impersonate the SA
resource "google_service_account_iam_member" "allow_workload_identity" {
  service_account_id = google_service_account.github_actions_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_owner}/${var.github_repo}"
}

output "service_account_email" {
  value = google_service_account.github_actions_sa.email
}

output "workload_identity_pool_name" {
  value = google_iam_workload_identity_pool.github_pool.name
}

output "workload_identity_provider_name" {
  value = google_iam_workload_identity_pool_provider.provider.name
}
