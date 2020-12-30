locals {
  networks = jsondecode(file("${path.module}/../networks.json"))
}

variable "statuspage_id" {
  type = string
}
