terraform {
  required_version = ">= 1.0"
  backend "gcs" {
    bucket = "thedevopsproject-terraform-state"
    prefix = "prod"
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
  name    = "thedevops-prod-vpc"
  subnets = [
    { name = "private-subnet-1" , cidr = "10.20.0.0/24" },
  ]
}

module "gke" {
  source     = "../../modules/gke"
  project    = var.project
  region     = var.region
  name       = "thedevops-prod-gke"
  network    = module.network.network_name
  subnetwork = module.network.subnet_names[0]
  preemptible = false
  machine_type = "e2-standard-2"
  node_count  = 2
}
