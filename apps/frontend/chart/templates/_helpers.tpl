{{- define "demo-frontend.name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{- define "demo-frontend.fullname" -}}
{{- printf "%s-%s" (include "demo-frontend.name" .) .Release.Name -}}
{{- end -}}
