variable "enabled" {
  description = "Create Memorystore Redis instance"
  type        = bool
  default     = false
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_id" {
  type    = string
  default = "redis-instance"
}

variable "tier" {
  description = "BASIC or STANDARD_HA"
  type        = string
  default     = "BASIC"
}

variable "memory_size_gb" {
  type    = number
  default = 1
}

variable "redis_version" {
  type    = string
  default = "REDIS_6_X"
}

variable "authorized_network" {
  description = "VPC network self_link for private service access"
  type        = string
  default     = ""
}
