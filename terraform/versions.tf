terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.51.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.15.0"
    }
    pagerduty = {
      source  = "pagerduty/pagerduty"
      version = "~> 1.8.0"
    }
    statuspage = {
      source  = "yannh/statuspage"
      version = "~> 0.1.6"
    }
  }
  required_version = ">= 0.13"
}
