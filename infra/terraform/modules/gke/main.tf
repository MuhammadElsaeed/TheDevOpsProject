resource "google_container_cluster" "primary" {
  name     = var.name
  project  = var.project
  # If a zone is provided, create a zonal cluster. Otherwise use the region.
  location = length(trimspace(var.zone)) > 0 ? var.zone : var.region
  initial_node_count = var.initial_node_count

  network    = var.network
  subnetwork = var.subnetwork

  remove_default_node_pool = true

  private_cluster_config {
    enable_private_nodes = var.enable_private_nodes
    master_ipv4_cidr_block = var.master_ipv4_cidr
  }

  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }

  # ip allocation will use default IP aliasing configured by the cluster
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-pool"
  project    = var.project
  location   = length(trimspace(var.zone)) > 0 ? var.zone : var.region
  cluster    = google_container_cluster.primary.name

  node_config {
  # GKE supports both preemptible and (newer) spot VMs. Spot will be used when
  # requested; otherwise fall back to preemptible setting.
  preemptible  = var.spot ? false : var.preemptible
  spot         = var.spot
  machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  disk_size_gb = var.disk_size_gb
  disk_type    = var.disk_type
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  initial_node_count = var.node_count
}

output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "endpoint" {
  value = google_container_cluster.primary.endpoint
}
