resource "google_compute_network" "vpc" {
  name                    = var.name
  auto_create_subnetworks = false
  project                 = var.project
}

resource "google_compute_subnetwork" "private" {
  count          = length(var.subnets)
  name           = element(var.subnets, count.index).name
  ip_cidr_range  = element(var.subnets, count.index).cidr
  region         = var.region
  network        = google_compute_network.vpc.id
  private_ip_google_access = true
  project        = var.project
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.name}-allow-internal"
  network = google_compute_network.vpc.name
  project = var.project

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  source_ranges = [var.internal_cidr]
  direction = "INGRESS"
}

output "network_name" {
  value = google_compute_network.vpc.name
}

output "subnet_names" {
  value = [for s in google_compute_subnetwork.private : s.name]
}
