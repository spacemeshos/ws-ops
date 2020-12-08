{{- range (datasource "networks") }}
{{- $confb64 := base64.Encode .conf -}}
{{- $peersb64 := base64.Encode .peers -}}
curl -s -o {{ $confb64 }} {{ .conf }}
curl -s -o {{ $peersb64 }} {{ .peers }}
{{- end -}}
