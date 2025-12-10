{{- define "demo-app.fullname" -}}
{{- .Values.name | default .Chart.Name -}}
{{- end -}}

{{- define "demo-app.name" -}}
{{- .Values.name | default .Chart.Name -}}
{{- end -}}
