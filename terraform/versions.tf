terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.51.0"
    }
    pagerduty = {
      source  = "pagerduty/pagerduty"
      version = "~> 1.8.0"
    }
  }
  required_version = ">= 0.13"
}
