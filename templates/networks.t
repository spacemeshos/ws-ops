{{- $script := slice }}

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
{{- $cmd := printf "helm upgrade --install -f %s %s ." $helmFile $name }}
{{- $script = $script | append $cmd }}
{{- end -}}

{{- range $script -}}
{{ . }}
{{- end -}}
