{{- define "hugoblog.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "hugoblog.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "hugoblog.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "hugoblog.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "hugoblog.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hugoblog.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "hugoblog.siteName" -}}
{{- .site.name | default .root.Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "hugoblog.siteFullname" -}}
{{- $siteName := include "hugoblog.siteName" . -}}
{{- if .root.Values.fullnameOverride -}}
{{- printf "%s-%s" .root.Values.fullnameOverride $siteName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .root.Release.Name $siteName | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "hugoblog.siteLabels" -}}
{{ include "hugoblog.labels" .root }}
app.kubernetes.io/site: {{ include "hugoblog.siteName" . }}
{{- end -}}

{{- define "hugoblog.siteSelectorLabels" -}}
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/site: {{ include "hugoblog.siteName" . }}
{{- end -}}
