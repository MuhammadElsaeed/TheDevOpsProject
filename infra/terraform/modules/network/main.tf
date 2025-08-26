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

# Reserve an IP range for Google services (used for Private Service Access)
resource "google_compute_global_address" "psa_range" {
  name          = "${var.name}-psa-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  # Required when reserving internal IP ranges for VPC peering
  network = google_compute_network.vpc.self_link
}

# Optional Cloud NAT to give private instances (GKE nodes without external IPs)
# outbound internet access. Enabled by default for clusters created in this module.
resource "google_compute_router" "nat_router" {
  count   = var.enable_nat ? 1 : 0
  name    = "${var.name}-nat-router"
  network = google_compute_network.vpc.self_link
  region  = var.region
  project = var.project
}

resource "google_compute_router_nat" "default_nat" {
  count = var.enable_nat ? 1 : 0
  name   = "${var.name}-nat"
  router = google_compute_router.nat_router[0].name
  region = var.region
  project = var.project

  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Create service networking peering to enable private services (Cloud SQL, Memorystore)
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa_range.name]
  # Make sure the reserved range is created first
  depends_on = [google_compute_global_address.psa_range]
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

output "vpc_self_link" {
  value = google_compute_network.vpc.self_link
}

output "psa_range_name" {
  value = google_compute_global_address.psa_range.name
}
