{{- $script := slice "helm repo add spacemesh https://spacemeshos.github.io/ws-helm-charts" }}

{{- define "api.yaml" -}}
netID: {{ .netID }}
image:
  tag: v{{ .maxNodeVersion }}
ingress:
  grpcDomain: {{ .grpcAPI | strings.TrimPrefix "https://" | strings.TrimSuffix "/" }}
  jsonRpcDomain: {{ .jsonAPI | strings.TrimPrefix "https://" | strings.TrimSuffix "/" }}
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
imageTag: github-actions
apiServer:
  image:
    repository: valar999sm/explorer-apiserver
  ingress:
    domain: {{ .explorer | strings.TrimPrefix "https://" | strings.TrimSuffix "/" }}
collector:
  image:
    repository: valar999sm/explorer-collector
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
