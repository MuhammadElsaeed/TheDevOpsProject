variable "project" {
  description = "GCP project id to provision resources into"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west4"
}

variable "bucket_name" {
  description = "Name of the GCS bucket to store Terraform state"
  type        = string
}

variable "create_kms" {
  description = "Whether to create a KMS key for encrypting the bucket"
  type        = bool
  default     = false
}

variable "kms_location" {
  description = "Location for KMS key ring"
  type        = string
  default     = "europe-west4"
}

variable "kms_keyring_name" {
  description = "Name for the KMS key ring"
  type        = string
  default     = "tf-keyring"
}

variable "kms_crypto_key_name" {
  description = "Name for the KMS crypto key"
  type        = string
  default     = "tf-crypto-key"
}

variable "github_owner" {
  description = "GitHub repository owner for Workload Identity trust (e.g. org or user)"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name for Workload Identity trust"
  type        = string
}

variable "github_oidc_pool_id" {
  description = "Workload Identity Pool id to create for GitHub Actions"
  type        = string
  default     = "github-actions-pool"
}

variable "github_oidc_provider_id" {
  description = "Provider id inside the workload identity pool"
  type        = string
  default     = "github-provider"
}

variable "github_sa_account_id" {
  description = "Service account account_id to create for GitHub Actions"
  type        = string
  default     = "github-actions-sa"
}

variable "artifact_repo_id" {
  description = "Artifact Registry repository id to create for Docker images"
  type        = string
  default     = "thedevops-repo"
}
