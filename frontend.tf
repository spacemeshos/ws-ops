resource "google_storage_bucket" "explorer" {
  name          = "spacemesh-explorer"
  location      = "EU"
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "google_storage_default_object_access_control" "explorer" {
  bucket = google_storage_bucket.explorer.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_compute_backend_bucket" "explorer" {
  name        = "spacemesh-explorer"
  bucket_name = google_storage_bucket.explorer.name
  enable_cdn  = true
}

resource "google_storage_bucket" "dash" {
  name          = "spacemesh-dash"
  location      = "EU"
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "google_storage_default_object_access_control" "dash" {
  bucket = google_storage_bucket.dash.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_compute_backend_bucket" "dash" {
  name        = "spacemesh-dash"
  bucket_name = google_storage_bucket.dash.name
  enable_cdn  = true
}

resource "google_compute_url_map" "main" {
  name            = "main"
  default_service = google_compute_backend_bucket.explorer.id

  host_rule {
    hosts = [
      for network in local.networks :
      "explorer-${network.netID}.spacemesh.io"
    ]
    path_matcher = "explorer"
  }

  host_rule {
    hosts = [
      "explorer.spacemesh.io"
    ]
    path_matcher = "explorer"
  }

  host_rule {
    hosts = [
      for network in local.networks :
      "dash-${network.netID}.spacemesh.io"
    ]
    path_matcher = "dash"
  }

  host_rule {
    hosts = [
      "dash.spacemesh.io"
    ]
    path_matcher = "dash"
  }

  path_matcher {
    name            = "explorer"
    default_service = google_compute_backend_bucket.explorer.id
  }

  path_matcher {
    name            = "dash"
    default_service = google_compute_backend_bucket.dash.id
  }
}

resource "google_compute_target_http_proxy" "main" {
  name    = "main"
  url_map = google_compute_url_map.main.id
}

resource "google_compute_global_address" "main" {
  name = "main"
}

resource "google_compute_global_forwarding_rule" "main" {
  name                  = "main"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.main.address
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.main.self_link
}
