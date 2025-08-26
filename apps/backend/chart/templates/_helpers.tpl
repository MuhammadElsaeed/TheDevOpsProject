{{- define "demo-backend.name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{- define "demo-backend.fullname" -}}
{{- printf "%s-%s" (include "demo-backend.name" .) .Release.Name -}}
{{- end -}}
