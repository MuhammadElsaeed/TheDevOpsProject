locals {
  create = var.enabled
}

resource "google_sql_database_instance" "this" {
  count = local.create ? 1 : 0

  name             = var.instance_name
  project          = var.project
  region           = var.region
  database_version = var.database_version

  settings {
    tier = var.tier

    backup_configuration {
      enabled = var.backup_enabled
    }

    disk_size = var.disk_size_gb
    ip_configuration {
      ipv4_enabled = var.ipv4_enabled
      # If a private_network self_link is provided, use it to enable private IP
      private_network = var.private_network != "" ? var.private_network : null
    }
  }
}

resource "google_sql_database" "default_db" {
  count    = local.create ? 1 : 0
  name     = "appdb"
  project  = var.project
  instance = google_sql_database_instance.this[0].name
}

# Optionally create an application user with provided password
resource "google_sql_user" "app_user" {
  count    = local.create ? 1 : 0
  name     = var.db_username
  instance = google_sql_database_instance.this[0].name
  project  = var.project
  password = var.db_password
}

output "instance_connection_name" {
  value = local.create ? google_sql_database_instance.this[0].connection_name : null
}
