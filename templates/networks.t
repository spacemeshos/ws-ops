{{- $script := slice "set -e" "helm repo add spacemesh https://spacemeshos.github.io/ws-helm-charts" -}}

{{- /* Values template for spacemesh-api */ -}}
{{- define "api.yaml" -}}
{{- $grpcURL := conv.URL .grpcAPI -}}
{{- $jsonURL := conv.URL .jsonAPI -}}
netID: {{ .netID }}
image:
  tag: v{{ .maxNodeVersion }}
pagerdutyToken: {{ .pagerdutyToken }}
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

{{- /* Values template for spacemesh-explorer */ -}}
{{- define "explorer.yaml" -}}
{{- $url := conv.URL .explorerAPI -}}
imageTag: v{{ .explorerVersion }}
pagerdutyToken: {{ .pagerdutyToken }}
apiServer:
  ingress:
    domain: {{ $url.Host }}
collector:
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

{{- /* Values template for spacemesh-dash */ -}}
{{- define "dash.yaml" -}}
{{- $url := conv.URL .dashAPI -}}
image:
  tag: v{{ .dashVersion }}
pagerdutyToken: {{ .pagerdutyToken }}
mongo: mongodb://spacemesh-explorer-{{ .netID }}-mongo
ingress:
  domain: {{ $url.Host }}
{{ end }}

{{- $nets := slice }}
{{- $terraform := (datasource "terraform") }}
{{- /* Main loop through networks */ -}}
{{- range $i, $item := (datasource "networks") }}
{{- $nets = $nets | append $item.netID }}
{{- $confData := $item.conf | base64.Encode | file.Read }}
{{- $confExplorerData := $item.explorerConf | base64.Encode | file.Read }}
{{- $peersData := $item.peers | base64.Encode | file.Read }}
{{- $addParams := dict "confData" $confData "confExplorerData" $confExplorerData "peersData" $peersData -}}

{{- $name := printf "spacemesh-api-%s" $item.netID }}
{{- $pagerdutyToken := index $terraform.pagerduty_api_key.value $i }}
{{- $params := (merge $item $addParams (dict "pagerdutyToken" $pagerdutyToken)) }}
{{- $helmFile := printf "%s.yaml" $name }}
{{- tmpl.Exec "api.yaml" $params | file.Write $helmFile }}
{{- $cmd := printf "helm upgrade --install -f %s %s spacemesh/spacemesh-api" $helmFile $name }}
{{- $script = $script | append $cmd -}}

{{- $name := printf "spacemesh-explorer-%s" $item.netID }}
{{- $pagerdutyToken := index $terraform.pagerduty_explorer_key.value $i }}
{{- $params := (merge $item $addParams (dict "pagerdutyToken" $pagerdutyToken)) }}
{{- $helmFile := printf "%s.yaml" $name }}
{{- tmpl.Exec "explorer.yaml" $params | file.Write $helmFile }}
{{- $cmd := printf "helm upgrade --install -f %s %s spacemesh/spacemesh-explorer" $helmFile $name }}
{{- $script = $script | append $cmd -}}

{{- $name := printf "spacemesh-dash-%s" $item.netID }}
{{- $pagerdutyToken := index $terraform.pagerduty_dash_key.value $i }}
{{- $params := (merge $item $addParams (dict "pagerdutyToken" $pagerdutyToken)) }}
{{- $helmFile := printf "%s.yaml" $name }}
{{- tmpl.Exec "dash.yaml" $params | file.Write $helmFile }}
{{- $cmd := printf "helm upgrade --install -f %s %s spacemesh/spacemesh-dash" $helmFile $name }}
{{- $script = $script | append $cmd -}}

{{- end -}}

{{- /* Delete missing networks */ -}}
{{ range (datasource "helms") }}
{{- if strings.HasPrefix "spacemesh-" .name }}
{{- $d := splitN .name "-" 3 }}
{{- if not (has $nets (index $d 2)) }}
{{- $cmd := printf "helm uninstall %s" .name }}
{{- $script = $script | append $cmd -}}
{{- end }}
{{- end }}
{{- end }}

{{- /* Output the script */ -}}
{{- range $script -}}
{{ . }}
{{ end -}}
