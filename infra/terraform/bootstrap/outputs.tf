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
