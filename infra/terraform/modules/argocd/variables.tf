variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}

variable "kube_token" {
  type    = string
  default = ""
}

variable "repo_url" {
  type = string
}

variable "target_revision" {
  type    = string
  default = "dev"
}

variable "backend_path" {
  type    = string
  default = "apps/backend/chart"
}

variable "frontend_path" {
  type    = string
  default = "apps/frontend/chart"
}
