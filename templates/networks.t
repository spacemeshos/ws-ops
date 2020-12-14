{{- $script := slice "helm repo add spacemesh https://spacemeshos.github.io/ws-helm-charts" }}

{{- define "helm.yaml" -}}
netID: {{ .netID }}
image:
  tag: v{{ .maxNodeVersion }}
ingress:
  grpcDomain: {{ .grpcAPI | strings.TrimPrefix "https://" | strings.TrimSuffix "/" }}
  jsonRpcDomain: {{ .jsonAPI | strings.TrimPrefix "https://" | strings.TrimSuffix "/" }}
resources:
  requests:
    cpu: 1000m
    memory: 2.2Gi
config: |
{{ .confData | indent 2 }}
peers: |
{{ .peersData | indent 2 }}
{{ end }}

{{- range (datasource "networks") }}
{{- $name := printf "api-%s" .netID }}
{{- $helmFile := printf "%s.yaml" $name }}
{{- $confData := .conf | base64.Encode | file.Read }}
{{- $peersData := .peers | base64.Encode | file.Read }}
{{- $addParams := dict "confData" $confData  "peersData" $peersData }}
{{- tmpl.Exec "helm.yaml" (merge . $addParams) | file.Write $helmFile }}
{{- $cmd := printf "helm upgrade --install -f %s %s spacemesh/spacemesh-api" $helmFile $name }}
{{- $script = $script | append $cmd }}
{{- end -}}

{{- range $script -}}
{{ . }}
{{ end -}}
