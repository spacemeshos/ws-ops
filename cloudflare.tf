resource "cloudflare_zone" "main" {
  zone = var.domain
}

resource "cloudflare_record" "explorer" {
  for_each = local.networks
  zone_id  = cloudflare_zone.main.id
  name     = "explorer-${local.networks[each.key].netID}"
  value    = google_compute_global_address.main.address
  type     = "A"
  proxied  = true
}

resource "cloudflare_record" "dash" {
  for_each = local.networks
  zone_id  = cloudflare_zone.main.id
  name     = "dash-${local.networks[each.key].netID}"
  value    = google_compute_global_address.main.address
  type     = "A"
  proxied  = true
}
