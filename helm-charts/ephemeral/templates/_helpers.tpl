{{ /* Expand the name of the chart */ }}

{{- define "ephemeral.appname" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/* Create a fully qualified app name */}}

{{- define "ephemeral.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | }}
{{- end }}
{{- end }}
{{- end }}

{{/* Create Chart Name and version as used by the chart label */}}

{{- define "ephemeral.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Common Labels */}}

{{- define "ephemeral.labels" -}}
helm.sh/chart: {{ include "ephemeral.chart" . }}
{{ include "ephemeral.selectorLabels" }}
{{- if .Chart.AppVersion  }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector Labels */}}

{{- define "ephemeral.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ephemeral.name" .}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Create the name of the service account to use */}}

{{- define "ephemeral.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ephemeral.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}