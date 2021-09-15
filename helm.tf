data "local_file" "config" {
  for_each = local.networks
  filename = "${path.module}/conf/${each.key}/config.json"
}

data "local_file" "explorer_config" {
  for_each = local.networks
  filename = "${path.module}/conf/${each.key}/explorer-config.json"
}

data "local_file" "peers" {
  for_each = local.networks
  filename = "${path.module}/conf/${each.key}/peers.json"
}

resource "helm_release" "api" {
  for_each   = local.networks
  name       = "spacemesh-api-${each.key}"
  repository = var.helm_repository
  chart      = "spacemesh-api"
  lint       = true
  wait       = false

  set {
    name  = "netID"
    value = each.key
  }

  set {
    name  = "image.repository"
    value = "${local.networks[each.key].repository}"
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

  values = [<<EOF
config: |
  ${indent(2, data.local_file.config[each.key].content)}
peers: |
  ${indent(2, data.local_file.peers[each.key].content)}
EOF
  ]
}

resource "helm_release" "explorer" {
  for_each   = local.networks
  name       = "spacemesh-explorer-${each.key}"
  repository = var.helm_repository
  chart      = "spacemesh-explorer"
  lint       = true
  wait       = false

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
    name  = "node.image.repository"
    value = "${local.networks[each.key].repository}"
  }

  set {
    name  = "node.image.tag"
    value = "v${local.networks[each.key].maxNodeVersion}"
  }

  set {
    name  = "node.netID"
    value = each.key
  }

  values = [<<EOF
node:
  config: |
    ${indent(4, data.local_file.explorer_config[each.key].content)}
  peers: |
    ${indent(4, data.local_file.peers[each.key].content)}
EOF
  ]
}

resource "helm_release" "dash" {
  for_each   = local.networks
  name       = "spacemesh-dash-${each.key}"
  repository = var.helm_repository
  chart      = "spacemesh-dash"
  lint       = true

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
