variable "enabled" {
  description = "Create the Cloud SQL instance"
  type        = bool
  default     = false
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_name" {
  description = "Cloud SQL instance name"
  type        = string
  default     = "postgres-instance"
}

variable "database_version" {
  type    = string
  default = "POSTGRES_14"
}

variable "tier" {
  type    = string
  default = "db-f1-micro"
}

variable "disk_size_gb" {
  type    = number
  default = 10
}

variable "backup_enabled" {
  type    = bool
  default = true
}

variable "ipv4_enabled" {
  description = "Whether to enable public IPv4 for the instance. Set to false to prefer private IP (requires network peering)."
  type    = bool
  default = true
}

variable "private_network" {
  description = "Optional VPC self_link to use for private IP (leave empty to skip)."
  type    = string
  default = ""
}

variable "db_username" {
  description = "Database user created for applications"
  type        = string
  default     = "appuser"
}

variable "db_password" {
  description = "Password for the application database user (empty = skip creating user)"
  type        = string
  default     = ""
}
