locals {
  networks = jsondecode(file("${path.module}/../networks.json"))
}

variable "domain" {
  default = "spacemesh.io"
}
variable "statuspage_id" {
  type = string
}
