{{- $script := slice "helm repo add spacemesh https://spacemeshos.github.io/ws-helm-charts" }}

{{- define "api.yaml" -}}
{{- $grpcURL := conv.URL .grpcAPI -}}
{{- $jsonURL := conv.URL .jsonAPI -}}
netID: {{ .netID }}
image:
  tag: v{{ .maxNodeVersion }}
ingress:
  grpcDomain: {{ $grpcURL.Host }}
  jsonRpcDomain: {{ $jsonURL.Host }}
resources:
  requests:
    cpu: 300m
    memory: 4Gi
config: |
{{ .confData | indent 2 }}
peers: |
{{ .peersData | indent 2 }}
{{ end }}

{{- define "explorer.yaml" -}}
{{- $url := conv.URL .explorerAPI -}}
imageTag: v{{ .explorerVersion }}
apiServer:
  image:
    repository: spacemeshos/explorer-apiserver
  ingress:
    domain: {{ $url.Host }}
collector:
  image:
    repository: spacemeshos/explorer-collector
  replicaCount: 2
node:
  image:
    tag: v{{ .maxNodeVersion }}
  resources:
    requests:
      cpu: 300m
      memory: 4Gi
  netID: {{ .netID }}
  config: |
{{ .confExplorerData | indent 4 }}
  peers: |
{{ .peersData | indent 4 }}
{{ end }}

{{- range (datasource "networks") }}
{{- $confData := .conf | base64.Encode | file.Read }}
{{- $confExplorerData := .explorerConf | base64.Encode | file.Read }}
{{- $peersData := .peers | base64.Encode | file.Read }}
{{- $addParams := dict "confData" $confData "confExplorerData" $confExplorerData "peersData" $peersData -}}

{{- $name := printf "spacemesh-api-%s" .netID }}
{{- $helmFile := printf "%s.yaml" $name }}
{{- tmpl.Exec "api.yaml" (merge . $addParams) | file.Write $helmFile }}
{{- $cmd := printf "helm upgrade --install -f %s %s spacemesh/spacemesh-api" $helmFile $name }}
{{- $script = $script | append $cmd -}}

{{- $name := printf "spacemesh-explorer-%s" .netID }}
{{- $helmFile := printf "%s.yaml" $name }}
{{- tmpl.Exec "explorer.yaml" (merge . $addParams) | file.Write $helmFile }}
{{- $cmd := printf "helm upgrade --install -f %s %s spacemesh/spacemesh-explorer" $helmFile $name }}
{{- $script = $script | append $cmd -}}

{{- end -}}

{{- range $script -}}
{{ . }}
{{ end -}}
