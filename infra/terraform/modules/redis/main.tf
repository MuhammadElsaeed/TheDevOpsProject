locals {
  create = var.enabled
}

resource "google_redis_instance" "this" {
  count = local.create ? 1 : 0

  name           = var.instance_id
  tier           = var.tier
  memory_size_gb = var.memory_size_gb
  region         = var.region
  project        = var.project

  redis_version = var.redis_version
  # If an authorized_network (VPC peering) is provided, set it.
  authorized_network = var.authorized_network != "" ? var.authorized_network : null
}

output "host" {
  value = local.create ? google_redis_instance.this[0].host : null
}

output "port" {
  value = local.create ? google_redis_instance.this[0].port : null
}
