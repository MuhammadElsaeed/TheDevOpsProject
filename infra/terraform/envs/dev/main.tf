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
}

module "redis" {
  source        = "../../modules/redis"
  enabled       = true
  project       = var.project
  region        = var.region
  instance_id   = "thedevops-dev-redis"
  tier          = "BASIC"
  memory_size_gb = 1
}
