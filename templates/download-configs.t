set -e
{{ range (datasource "networks") }}
{{- $confb64 := base64.Encode .conf -}}
{{- $confexplorerb64 := base64.Encode .explorerConf -}}
{{- $peersb64 := base64.Encode .peers -}}
curl -s -o {{ $confb64 }} {{ .conf }}
curl -s -o {{ $confexplorerb64 }} {{ .explorerConf }}
curl -s -o {{ $peersb64 }} {{ .peers }}
{{- end -}}
