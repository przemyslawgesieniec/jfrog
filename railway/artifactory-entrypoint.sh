#!/usr/bin/env bash
set -euo pipefail

public_port="${PORT:-8080}"
system_yaml="/var/opt/jfrog/artifactory/etc/system.yaml"
template_yaml="/opt/jfrog/artifactory/app/misc/etc/system.full-template.yaml"

configure_jfconnect() {
  mkdir -p "$(dirname "$system_yaml")"

  if [[ ! -f "$system_yaml" && -f "$template_yaml" ]]; then
    cp "$template_yaml" "$system_yaml"
  fi

  if [[ -f "$system_yaml" ]]; then
    if grep -q '^jfconnect:' "$system_yaml"; then
      sed -i '/^jfconnect:/,/^[^[:space:]]/ s/^\([[:space:]]*enabled:[[:space:]]*\).*/\1false/' "$system_yaml"
    else
      printf '\njfconnect:\n    enabled: false\n' >> "$system_yaml"
    fi
  fi
}

if [[ "$public_port" != "8082" ]]; then
  socat "TCP-LISTEN:${public_port},fork,reuseaddr,bind=0.0.0.0" TCP:127.0.0.1:8082 &
fi

configure_jfconnect

exec /bin/bash /entrypoint-artifactory.sh "$@"
