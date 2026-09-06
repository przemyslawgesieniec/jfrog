#!/usr/bin/env bash
set -euo pipefail

public_port="${PORT:-8080}"

if [[ "$public_port" != "8082" ]]; then
  socat "TCP-LISTEN:${public_port},fork,reuseaddr,bind=0.0.0.0" TCP:127.0.0.1:8082 &
fi

exec /bin/bash /entrypoint-artifactory.sh "$@"
