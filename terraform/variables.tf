locals {
  networks = {
    for net in jsondecode(file("${path.module}/../networks.json")) :
    net.netID => net
  }
}

variable "domain" {
  default = "spacemesh.io"
}

variable "helm_repository" {
  default = "https://spacemeshos.github.io/ws-helm-charts"
}

variable "statuspage_id" {
  type = string
}
