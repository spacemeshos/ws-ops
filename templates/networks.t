{{- $script := slice "helm repo add spacemesh https://spacemeshos.github.io/ws-helm-charts" }}

{{- define "helm.yaml" -}}
configFile: {{ .netID }}.conf
ingress:
  grpcDomain: {{ .grpcAPI | strings.TrimPrefix "https://" | strings.TrimSuffix "/" }}
  jsonRpcDomain: {{ .jsonAPI | strings.TrimPrefix "https://" | strings.TrimSuffix "/" }}
{{ end }}

{{- range (datasource "networks") }}
{{- $name := printf "sm-%s" .netID }}
{{- $helmFile := printf "%s.yaml" $name }}
{{- tmpl.Exec "helm.yaml" . | file.Write $helmFile }}
{{- $cmd := printf "helm upgrade --install -f %s %s spacemesh/spacemesh-api" $helmFile $name }}
{{- $script = $script | append $cmd }}
{{- end -}}

{{- range $script -}}
{{ . }}
{{ end -}}
