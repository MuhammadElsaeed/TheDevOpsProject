variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "enable_private_nodes" {
  type = bool
  default = true
}

variable "master_ipv4_cidr" {
  type = string
  default = "172.16.0.0/28"
}

variable "preemptible" {
  type = bool
  default = true
}

variable "spot" {
  description = "Use GCE Spot VMs for the node pool (preferred over preemptible where available)"
  type = bool
  default = false
}

variable "machine_type" {
  type = string
  default = "e2-medium"
}

variable "node_count" {
  type = number
  default = 1
}
variable "zone" {
  description = "Optional zone for zonal clusters (e.g. europe-west4-a). If empty, the module will create a regional cluster using var.region."
  type = string
  default = ""
}

variable "initial_node_count" {
  description = "Initial node count for the cluster default node pool. Set to 1 when removing default node pool to satisfy API requirements."
  type = number
  default = 1
}

variable "disk_size_gb" {
  description = "Boot disk size (GB) for nodes"
  type        = number
  default     = 30
}

variable "disk_type" {
  description = "Disk type for node boot disks, e.g. pd-standard or pd-ssd"
  type        = string
  default     = "pd-ssd"
}
