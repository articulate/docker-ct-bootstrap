#!/bin/bash -e

## Global Secrets - STAGE (old, deprecated style)
{{range secrets "secret/global/stage/env_vars" -}}
{{if not (env (. | toUpper)) -}}
export {{ . | toUpper}}{{with secret (printf "secret/global/stage/env_vars/%s" .) }}="{{.Data.value}}"{{end}}
{{end -}}
{{end -}}

# Global Secrets - STAGE (new style)
{{range secrets "secret/global/env_vars" -}}
{{if not (env (. | toUpper)) -}}
export {{ . | toUpper}}{{with secret (printf "secret/global/env_vars/%s" .) }}="{{.Data.value}}"{{end}}
{{end -}}
{{end -}}

# Product Secrets - STAGE
{{if (env "SERVICE_PRODUCT") -}}
{{range secrets (printf "secret/products/%s/env_vars" (env "SERVICE_PRODUCT")) -}}
{{if not (env (. | toUpper)) -}}
export {{ . | toUpper}}{{with secret (printf "secret/products/%s/env_vars/%s" (env "SERVICE_PRODUCT") .) }}="{{.Data.value}}"{{end}}
{{end -}}
{{end -}}
{{end -}}

# App Secrets - STAGE (old, deprecated style)
{{range secrets (printf "secret/apps/%s/stage/env_vars" (env "SERVICE_NAME")) -}}
{{if not (env (. | toUpper)) -}}
export {{ . | toUpper}}{{with secret (printf "secret/apps/%s/stage/env_vars/%s" (env "SERVICE_NAME") .) }}="{{.Data.value}}"{{end}}
{{end -}}
{{end -}}

# App Secrets - STAGE (new style)
{{range secrets (printf "secret/services/%s/env_vars" (env "SERVICE_NAME")) -}}
{{if not (env (. | toUpper)) -}}
export {{ . | toUpper}}{{with secret (printf "secret/services/%s/env_vars/%s" (env "SERVICE_NAME") .) }}="{{.Data.value}}"{{end}}
{{end -}}
{{end -}}



## Global Secrets - DEV
{{range secrets "secret/global/dev/env_vars" -}}
{{if not (env (. | toUpper)) -}}
export {{ . | toUpper}}{{with secret (printf "secret/global/dev/env_vars/%s" .) }}="{{.Data.value}}"{{end}}
{{end -}}
{{end -}}

# Product Secrets - DEV
{{if (env "SERVICE_PRODUCT") -}}
{{range secrets (printf "secret/products/%s/dev/env_vars" (env "SERVICE_PRODUCT")) -}}
export {{ . | toUpper}}{{with secret (printf "secret/products/%s/dev/env_vars/%s" (env "SERVICE_PRODUCT") .) }}="{{.Data.value}}"{{end}}
{{end -}}
{{end -}}

# App Secrets - DEV
{{range secrets (printf "secret/apps/%s/dev/env_vars" (env "SERVICE_NAME")) -}}
{{if not (env (. | toUpper)) -}}
export {{ . | toUpper}}{{with secret (printf "secret/apps/%s/dev/env_vars/%s" (env "SERVICE_NAME") .) }}="{{.Data.value}}"{{end}}
{{end -}}
{{end -}}
