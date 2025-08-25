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
