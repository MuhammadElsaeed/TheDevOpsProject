terraform {
  required_version = ">= 1.0"
  backend "gcs" {
    bucket = "thedevopsproject-terraform-state"
    prefix = "dev"
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

# Use google-beta for Secret Manager resources (some schemas differ)
provider "google-beta" {
  project = var.project
  region  = var.region
}

resource "google_service_account" "app_sa" {
  account_id   = "thedevops-app-sa"
  display_name = "Application service account for dev"
  project      = var.project
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "random_password" "redis_token" {
  length  = 32
  special = true
}

# Secret Manager: store DB credentials and Redis token
resource "google_secret_manager_secret" "db_secret" {
  provider  = google
  secret_id = "dev-db-credentials"
  project   = var.project
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_secret_value" {
  provider    = google
  secret      = google_secret_manager_secret.db_secret.id
  secret_data = jsonencode({ username = "appuser", password = random_password.db_password.result })
}

resource "google_secret_manager_secret" "redis_secret" {
  provider  = google
  secret_id = "dev-redis-token"
  project   = var.project
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "redis_secret_value" {
  provider    = google
  secret      = google_secret_manager_secret.redis_secret.id
  secret_data = random_password.redis_token.result
}

resource "google_secret_manager_secret_iam_member" "db_reader" {
  provider  = google
  secret_id = google_secret_manager_secret.db_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.app_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "redis_reader" {
  provider  = google
  secret_id = google_secret_manager_secret.redis_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.app_sa.email}"
}

module "network" {
  source  = "../../modules/network"
  project = var.project
  region  = var.region
  name    = "thedevops-dev-vpc"
  subnets = [
    { name = "private-subnet-1" , cidr = "10.10.0.0/24" },
  ]
}

module "gke" {
  source     = "../../modules/gke"
  project    = var.project
  region     = var.region
  name       = "thedevops-dev-gke"
  network    = module.network.network_name
  subnetwork = module.network.subnet_names[0]
  preemptible = true
  spot        = true
  node_count  = 1
  disk_size_gb = 30
  disk_type   = "pd-standard"
  zone        = "europe-west4-a"
}

# Install ArgoCD and create Applications (uses gcloud token fallback when run locally)
module "argocd" {
  source = "../../modules/argocd"

  cluster_endpoint       = module.gke.endpoint
  cluster_ca_certificate = module.gke.cluster_ca_certificate
  kube_token             = "" # leave empty to use gcloud token when running locally or set via CI
  repo_url               = "https://github.com/MuhammadElsaeed/TheDevOpsProject"
  target_revision        = "dev"
  backend_path           = "apps/backend/chart"
  frontend_path          = "apps/frontend/chart"
}

module "sql" {
  source        = "../../modules/sql"
  enabled       = true
  project       = var.project
  region        = var.region
  instance_name = "thedevops-dev-sql"
  database_version = "POSTGRES_14"
  tier = "db-f1-micro"
  disk_size_gb = 10
  ipv4_enabled = true
  # Use private network if available from the network module
  private_network = module.network.vpc_self_link
  db_username = "appuser"
  db_password = random_password.db_password.result
  depends_on = [module.network]
}

module "redis" {
  source        = "../../modules/redis"
  enabled       = true
  project       = var.project
  region        = var.region
  instance_id   = "thedevops-dev-redis"
  tier          = "BASIC"
  memory_size_gb = 1
  # Use the reserved PSA range name as the authorized_network (supported by Memorystore when using VPC peering)
  authorized_network = module.network.vpc_self_link
  # Redis uses VPC authorization; auth token is not set here
  depends_on = [module.network]
}

output "dev_db_credentials" {
  value     = jsonencode({ username = "appuser", password = random_password.db_password.result })
  sensitive = true
}

output "dev_redis_endpoint" {
  value = module.redis.host
  sensitive = true
}
