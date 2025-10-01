#!/usr/bin/env bash
set -euo pipefail

# check_prowlarr.sh
# Simple health/indexer verification for Prowlarr.
#
# Usage:
#   PROWLARR_API_KEY=your_key ./scripts/check_prowlarr.sh
# or, if you have an encrypted secrets file and sops installed:
#   ./scripts/check_prowlarr.sh
#
# The script prefers PROWLARR_API_KEY environment variable. If not set, and if
# sops is installed and docs/secrets/prowlarr-r0xyd0g.enc.yaml exists, it will
# attempt to decrypt and extract the api_key using yq.
#
# Requirements (recommended):
#   - curl
#   - sops (optional, for decrypting encrypted secrets)
#   - yq (optional, for YAML parsing)
#
# Notes:
# - The script uses the base URL from PROWLARR_BASE_URL env var if set,
#   otherwise defaults to https://r0xyd0g.agate.usbx.me:9696
# - It will print HTTP status codes and the first ~1000 bytes of returned JSON.

# Helpers
die() { echo "$@" >&2; exit 1; }

# Obtain API key
if [ -n "${PROWLARR_API_KEY:-}" ]; then
  API_KEY="$PROWLARR_API_KEY"
else
  if command -v sops >/dev/null 2>&1 && [ -f "docs/secrets/prowlarr-r0xyd0g.enc.yaml" ]; then
    if command -v yq >/dev/null 2>&1; then
      API_KEY=$(sops -d docs/secrets/prowlarr-r0xyd0g.enc.yaml 2>/dev/null | yq -r '.api_key')
    else
      die "PROWLARR_API_KEY not set and yq not found. Install yq or set PROWLARR_API_KEY."
    fi
  else
    die "PROWLARR_API_KEY not set and encrypted secrets not available (or sops missing). Set PROWLARR_API_KEY or install sops and yq."
  fi
fi

BASE_URL="${PROWLARR_BASE_URL:-https://r0xyd0g.agate.usbx.me:9696}"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

ENDPOINTS=(
  "/api/v1/indexer"
  "/api/v1/system/status"
)

for ep in "${ENDPOINTS[@]}"; do
  url="$BASE_URL$ep"
  echo "----"
  echo "GET $url"
  http_code=$(curl -sS -H "X-Api-Key: $API_KEY" -k -o "$TMPDIR/resp.json" -w "%{http_code}" "$url" || echo "000")
  echo "HTTP $http_code"
  if [ -s "$TMPDIR/resp.json" ]; then
    echo "Response (first 1000 bytes):"
    head -c 1000 "$TMPDIR/resp.json" || true
    echo
  else
    echo "No response body saved."
  fi
done

echo "----"
echo "Check complete. If connection failed (000 or connection refused), verify:"
echo "- Prowlarr service is running on the host (systemctl / docker ps)"
echo "- Reverse proxy (nginx/Traefik) is forwarding /prowlarr to the internal port"
echo "- Ports and firewall allow access from this machine"
