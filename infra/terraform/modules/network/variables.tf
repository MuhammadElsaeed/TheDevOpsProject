variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "subnets" {
  description = "List of maps with name and cidr for each subnet"
  type = list(object({ name = string, cidr = string }))
}

variable "internal_cidr" {
  type = string
  default = "10.0.0.0/8"
}
