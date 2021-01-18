locals {
  networks = {
    for net in jsondecode(file("${path.module}/../networks.json")) : net.netID => net
  }
}

variable "domain" {
  default = "spacemesh.io"
}
variable "statuspage_id" {
  type = string
}
