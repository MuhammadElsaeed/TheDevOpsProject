output "github_actions_service_account_email" {
  value       = module.github_oidc.service_account_email
  description = "Email of the service account created for GitHub Actions"
}

output "github_oidc_provider_name" {
  value       = module.github_oidc.workload_identity_provider_name
  description = "Full resource name of the workload identity provider"
}
output "bucket_name" {
  description = "GCS bucket used for Terraform state"
  value       = google_storage_bucket.tfstate.name
}

output "bucket_self_link" {
  value = google_storage_bucket.tfstate.self_link
}

output "kms_key_id" {
  value = var.create_kms ? google_kms_crypto_key.tf[0].id : null
}
