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
  count                   = length(local.networks)
  name                    = "api-${local.networks[count.index].netID}"
  escalation_policy       = pagerduty_escalation_policy.main.id
  acknowledgement_timeout = "null"
  auto_resolve_timeout    = "null"
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service" "explorer" {
  count                   = length(local.networks)
  name                    = "explorer-${local.networks[count.index].netID}"
  escalation_policy       = pagerduty_escalation_policy.main.id
  acknowledgement_timeout = "null"
  auto_resolve_timeout    = "null"
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service" "dash" {
  count                   = length(local.networks)
  name                    = "dash-${local.networks[count.index].netID}"
  escalation_policy       = pagerduty_escalation_policy.main.id
  acknowledgement_timeout = "null"
  auto_resolve_timeout    = "null"
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "api" {
  count   = length(local.networks)
  name    = "api-${local.networks[count.index].netID}"
  type    = "events_api_v2_inbound_integration"
  service = pagerduty_service.api[count.index].id
}

resource "pagerduty_service_integration" "explorer" {
  count   = length(local.networks)
  name    = "explorer-${local.networks[count.index].netID}"
  type    = "events_api_v2_inbound_integration"
  service = pagerduty_service.explorer[count.index].id
}

resource "pagerduty_service_integration" "dash" {
  count   = length(local.networks)
  name    = "dash-${local.networks[count.index].netID}"
  type    = "events_api_v2_inbound_integration"
  service = pagerduty_service.dash[count.index].id
}
