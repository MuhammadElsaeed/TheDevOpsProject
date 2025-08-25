output "instance_name" {
  value = var.enabled ? var.instance_name : null
}

output "connection_name" {
  value = var.enabled ? google_sql_database_instance.this[0].connection_name : null
}
