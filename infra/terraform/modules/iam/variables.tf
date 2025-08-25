variable "project" {
  type = string
}

variable "account_id" {
  type = string
}

variable "display_name" {
  type = string
}

variable "roles" {
  type = map(string)
  default = {}
}
