data "http" "config" {
  for_each = local.networks
  url      = "https://discover.spacemesh.io/conf/${each.key}/config.json"
  request_headers = {
    Accept = "application/json"
  }
}

data "http" "peers" {
  for_each = local.networks
  url      = "https://discover.spacemesh.io/conf/${each.key}/peers.json"
  request_headers = {
    Accept = "application/json"
  }
}

resource "helm_release" "api" {
  for_each   = local.networks
  name       = "spacemesh-api-${each.key}"
  repository = var.helm_repository
  chart      = "spacemesh-api"

  set {
    name  = "netID"
    value = each.key
  }

  set {
    name  = "image.tag"
    value = "v${local.networks[each.key].maxNodeVersion}"
  }

  set {
    name  = "ingress.grpcDomain"
    value = "api-${each.key}.spacemesh.io"
  }

  set {
    name  = "ingress.jsonRpcDomain"
    value = "api-json-${each.key}.spacemesh.io"
  }

  set {
    name  = "resources.requests.cpu"
    value = "300m"
  }

  set {
    name  = "resources.requests.memory"
    value = "4Gi"
  }

  set_sensitive {
    name  = "pagerdutyToken"
    value = pagerduty_service_integration.api[each.key].integration_key
  }

  set {
    name  = "config"
    value = data.http.config[each.key].body
  }

  set {
    name  = "peers"
    value = data.http.peers[each.key].body
  }
}

resource "helm_release" "explorer" {
  for_each   = local.networks
  name       = "spacemesh-explorer-${each.key}"
  repository = var.helm_repository
  chart      = "spacemesh-explorer"

  set {
    name  = "imageTag"
    value = "v${local.networks[each.key].explorerVersion}"
  }

  set {
    name  = "apiServer.ingress.domain"
    value = "explorer-api-${each.key}.spacemesh.io"
  }

  set {
    name  = "collector.replicaCount"
    value = 2
  }

  set_sensitive {
    name  = "pagerdutyToken"
    value = pagerduty_service_integration.explorer[each.key].integration_key
  }

  set {
    name  = "node.resources.requests.cpu"
    value = "300m"
  }

  set {
    name  = "node.resources.requests.memory"
    value = "4Gi"
  }

  set {
    name  = "node.image.tag"
    value = "v${local.networks[each.key].maxNodeVersion}"
  }

  set {
    name  = "node.netID"
    value = each.key
  }

  set {
    name  = "node.config"
    value = data.http.config[each.key].body
  }

  set {
    name  = "node.peers"
    value = data.http.peers[each.key].body
  }
}

resource "helm_release" "dash" {
  for_each   = local.networks
  name       = "spacemesh-dash-${each.key}"
  repository = var.helm_repository
  chart      = "spacemesh-dash"

  set {
    name  = "image.tag"
    value = "v${local.networks[each.key].dashVersion}"
  }

  set {
    name  = "mongo"
    value = "mongodb://spacemesh-explorer-${each.key}-mongo"
  }

  set {
    name  = "ingress.domain"
    value = "dash-api-${each.key}.spacemesh.io"
  }

  set_sensitive {
    name  = "pagerdutyToken"
    value = pagerduty_service_integration.dash[each.key].integration_key
  }
}
