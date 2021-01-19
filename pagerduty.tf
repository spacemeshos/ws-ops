resource "pagerduty_user" "aviv" {
  name        = "Aviv Eyal"
  email       = "avive@spacemesh.io"
  description = ""
  role        = "owner"
}

resource "pagerduty_escalation_policy" "main" {
  name = "DevOps Escalation Policy"
  rule {
    escalation_delay_in_minutes = 5
    target {
      id = pagerduty_user.aviv.id
    }
  }
}

resource "pagerduty_service" "api" {
  for_each                = local.networks
  name                    = "api-${each.key}"
  escalation_policy       = pagerduty_escalation_policy.main.id
  acknowledgement_timeout = "null"
  auto_resolve_timeout    = "null"
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service" "explorer" {
  for_each                = local.networks
  name                    = "explorer-${each.key}"
  escalation_policy       = pagerduty_escalation_policy.main.id
  acknowledgement_timeout = "null"
  auto_resolve_timeout    = "null"
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service" "dash" {
  for_each                = local.networks
  name                    = "dash-${each.key}"
  escalation_policy       = pagerduty_escalation_policy.main.id
  acknowledgement_timeout = "null"
  auto_resolve_timeout    = "null"
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "api" {
  for_each = local.networks
  name     = "api-${each.key}"
  type     = "events_api_v2_inbound_integration"
  service  = pagerduty_service.api[each.key].id
}

resource "pagerduty_service_integration" "explorer" {
  for_each = local.networks
  name     = "explorer-${local.networks[each.key].netID}"
  type     = "events_api_v2_inbound_integration"
  service  = pagerduty_service.explorer[each.key].id
}

resource "pagerduty_service_integration" "dash" {
  for_each = local.networks
  name     = "dash-${local.networks[each.key].netID}"
  type     = "events_api_v2_inbound_integration"
  service  = pagerduty_service.dash[each.key].id
}
