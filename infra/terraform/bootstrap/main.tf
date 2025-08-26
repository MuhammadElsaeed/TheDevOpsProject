terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

module "github_oidc" {
  source         = "../modules/github_oidc"
  project        = var.project
  pool_id        = var.github_oidc_pool_id
  provider_id    = var.github_oidc_provider_id
  sa_account_id  = var.github_sa_account_id
  github_owner   = var.github_owner
  github_repo    = var.github_repo
}

resource "google_artifact_registry_repository" "docker_repo" {
  provider = google
  project  = var.project
  location = var.region
  repository_id = var.artifact_repo_id
  description = "Artifact Registry repository for container images"
  format = "DOCKER"
}



provider "google" {
  project = var.project
  region  = var.region
}

# Enable core APIs used by later stages. Enabling here reduces chance of failures later.
locals {
  apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "iam.googleapis.com",
  "cloudresourcemanager.googleapis.com",
    "storage.googleapis.com",
    "cloudkms.googleapis.com",
    "redis.googleapis.com",
  "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "servicenetworking.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
  ]
}

resource "google_project_service" "required_apis" {
  for_each = toset(local.apis)
  project  = var.project
  service  = each.key
  disable_on_destroy = false
}

# Optional KMS keyring + crypto key for bucket CMEK (if create_kms = true)
resource "google_kms_key_ring" "tf" {
  count   = var.create_kms ? 1 : 0
  name    = var.kms_keyring_name
  location = var.kms_location
  project = var.project
}

resource "google_kms_crypto_key" "tf" {
  count            = var.create_kms ? 1 : 0
  name             = var.kms_crypto_key_name
  key_ring         = google_kms_key_ring.tf[0].id
  rotation_period  = "7776000s" # 90 days
}

# GCS bucket to hold Terraform remote state. Use uniform bucket-level access and versioning.
resource "google_storage_bucket" "tfstate" {
  name     = var.bucket_name
  project  = var.project
  location = var.region

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition {
      age = 365
    }
  }

  # If create_kms true, set default_kms_key_name to the crypto key resource name
  dynamic "encryption" {
    for_each = var.create_kms ? [1] : []
    content {
      default_kms_key_name = google_kms_crypto_key.tf[0].id
    }
  }

  labels = {
    managed_by = "thedevopsproject"
    purpose    = "terraform-state"
  }
}

