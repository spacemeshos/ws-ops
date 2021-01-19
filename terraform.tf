provider "google" {
  project = "explore-293719"
}

provider "helm" {
  kubernetes {
    config_path = var.kube_config
  }
}

terraform {
  backend "remote" {
    organization = "spacemeshos"
    workspaces {
      name = "ws-ops"
    }
  }
}
