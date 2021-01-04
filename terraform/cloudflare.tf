resource "cloudflare_zone" "main" {
  zone = var.domain
}

resource "cloudflare_record" "explorer" {
  count   = length(local.networks)
  zone_id = cloudflare_zone.main.id
  name    = "explorer-${local.networks[count.index].netID}"
  value   = google_compute_global_address.main.address
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "dash" {
  count   = length(local.networks)
  zone_id = cloudflare_zone.main.id
  name    = "dash-${local.networks[count.index].netID}"
  value   = google_compute_global_address.main.address
  type    = "A"
  proxied = true
}
