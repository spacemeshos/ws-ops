resource "statuspage_component" "api" {
  count   = length(local.networks)
  page_id = var.statuspage_id
  name    = "Spacemesh ${local.networks[count.index].netName} Public API"
  status  = "operational"
}

resource "statuspage_component" "explorer" {
  count   = length(local.networks)
  page_id = var.statuspage_id
  name    = "Spacemesh ${local.networks[count.index].netName} Explorer"
  status  = "operational"
}

resource "statuspage_component" "dash" {
  count   = length(local.networks)
  page_id = var.statuspage_id
  name    = "Spacemesh ${local.networks[count.index].netName} Dashboard"
  status  = "operational"
}
