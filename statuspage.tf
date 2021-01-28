resource "statuspage_component" "api" {
  for_each = local.networks
  page_id  = var.statuspage_id
  name     = "Spacemesh ${local.networks[each.key].netName} Public API"
  status   = "operational"
}

resource "statuspage_component" "explorer" {
  for_each = local.networks
  page_id  = var.statuspage_id
  name     = "Spacemesh ${local.networks[each.key].netName} Explorer"
  status   = "operational"
}

resource "statuspage_component" "dash" {
  for_each = local.networks
  page_id  = var.statuspage_id
  name     = "Spacemesh ${local.networks[each.key].netName} Dashboard"
  status   = "operational"
}

resource "statuspage_component" "discover" {
  page_id = var.statuspage_id
  name    = "Spacemesh Discover Service"
  status  = "operational"
}
