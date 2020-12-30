provider "google" {
  project = "explore-293719"
}

provider "pagerduty" {
}

terraform {
  backend "remote" {
    organization = "spacemeshos"
    workspaces {
      name = "ws-ops"
    }
  }
}
