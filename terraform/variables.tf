locals {
  networks = jsondecode(file("${path.module}/../networks.json"))
}
