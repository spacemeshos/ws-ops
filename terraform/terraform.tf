provider "google" {
  project = "explore-293719"
}

provider "pagerduty" {
}

provider "statuspage" {
}

terraform {
  backend "remote" {
    organization = "spacemeshos"
    workspaces {
      name = "ws-ops"
    }
  }
}
