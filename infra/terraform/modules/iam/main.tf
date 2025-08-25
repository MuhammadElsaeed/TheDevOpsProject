resource "google_service_account" "sa" {
  account_id   = var.account_id
  display_name = var.display_name
  project      = var.project
}

resource "google_project_iam_member" "sa_roles" {
  for_each = toset(var.roles)
  project = var.project
  role    = each.key
  member  = "serviceAccount:${google_service_account.sa.email}"
}

output "service_account_email" {
  value = google_service_account.sa.email
}
