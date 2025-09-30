#!/usr/bin/env bash

# manage-containers.sh — script to start, stop, or update all services under /srv/docker
# Usage: ./manage-containers.sh start|stop|update

set -e

SERVICES=(
  whisparr
  chrome-headless
  stash
  pv2mqtt
  openvpn-as
  radarr
  prowlarr
  overseerr
  sonarr
  cloudflared
  
)

COMMAND="$1"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "$COMMAND" ]]; then
  echo "Error: no command. Usage: $0 {start|stop|update}"
  exit 1
fi

for svc in "${SERVICES[@]}"; do
  DIR="$BASE_DIR/$svc"
  if [[ -d "$DIR" ]]; then
    echo "[$svc] $COMMAND"
    cd "$DIR"
    case "$COMMAND" in
      start)
        docker compose up -d
        ;;
      ls)
        docker compose ls -a
        ;;
      stop)
        docker compose down
        ;;
      update)
        docker compose pull && docker compose up -d
        ;;
      *)
        echo "Invalid command: $COMMAND (use start, stop, or update)"
        exit 1
        ;;
    esac
  else
    echo "Warning: directory not found: $DIR"
  fi
done
