output "pagerduty_api_key" {
  value = pagerduty_service_integration.api[*].integration_key
}

output "pagerduty_explorer_key" {
  value = pagerduty_service_integration.explorer[*].integration_key
}

output "pagerduty_dash_key" {
  value = pagerduty_service_integration.dash[*].integration_key
}
