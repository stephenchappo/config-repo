#!/usr/bin/env bash
# scripts/check_prowlarr.sh
#
# Connectivity / API checks for Prowlarr.
# - Prefer to read API key from docs/secrets/prowlarr-r0xyd0g.enc.yaml via sops (if available).
# - Fallback to PROWLARR_API_KEY env var or second CLI arg.
# - Usage:
#     PROWLARR_API_KEY=your_key PROWLARR_URL=http://host:9696 ./scripts/check_prowlarr.sh
#     ./scripts/check_prowlarr.sh http://host:9696 your_key
#     ./scripts/check_prowlarr.sh        # will try sops decrypt then env var then default host
#
# Security:
# - This script will not write secrets to disk. If using sops, the decrypted content stays in memory.
# - Do NOT commit plaintext API keys to the repository.

set -euo pipefail
IFS=$'\n\t'

SOPS_FILE="docs/secrets/prowlarr-r0xyd0g.enc.yaml"
DEFAULT_HOST="http://192.168.1.100:9696"

usage() {
  cat <<EOF
Usage:
  PROWLARR_API_KEY=your_key PROWLARR_URL=http://host:9696 $0
  $0 http://host:9696 your_key

If available, this script will attempt to read the API key from:
  $SOPS_FILE (requires 'sops' to be installed and decryption keys available).
EOF
}

# Determine host
HOST="${1:-${PROWLARR_URL:-$DEFAULT_HOST}}"

# Determine API key (arg2 -> env -> sops decrypted file)
API_KEY="${2:-${PROWLARR_API_KEY:-}}"

# Try sops-decrypt if no API key provided and file exists
if [ -z "$API_KEY" ] && [ -f "$SOPS_FILE" ] && command -v sops >/dev/null 2>&1; then
  echo "Attempting to decrypt API key from $SOPS_FILE using sops..." >&2
  if command -v yq >/dev/null 2>&1; then
    # Use yq if available for robust YAML parsing
    API_KEY="$(sops -d "$SOPS_FILE" 2>/dev/null | yq -r '.api_key' 2>/dev/null || true)"
  else
    # Fallback to a simple sed extraction (works for "api_key: value" lines)
    API_KEY="$(sops -d "$SOPS_FILE" 2>/dev/null | sed -n 's/^[[:space:]]*api_key:[[:space:]]*//p' | tr -d '\"' || true)"
  fi
fi

if [ -z "$API_KEY" ]; then
  echo "ERROR: No API key provided." >&2
  usage
  exit 2
fi

# Normalize host (remove trailing slash)
HOST="${HOST%/}"

CURL_OPTS=( -sS --connect-timeout 5 --max-time 15 -H"X-Api-Key: $API_KEY" )

# Temporary file for responses
TMPRESP="$(mktemp /tmp/prowlarr_resp.XXXXXX)"
cleanup() { rm -f "$TMPRESP"; }
trap cleanup EXIT

# Unicode / ASCII marks for success/failure. Export PROWLARR_ASCII=1 to force ASCII fallback.
if [ "${PROWLARR_ASCII:-0}" = "1" ]; then
  mark_ok="[OK]"
  mark_fail="[FAIL]"
else
  mark_ok="✓"
  mark_fail="✗"
fi

check() {
  local url="$1"
  printf "Checking %s ... " "$url"
  local curl_rc=0
  local http_code
  # Capture HTTP code and response body
  http_code="$(curl "${CURL_OPTS[@]}" -w '%{http_code}' -o "$TMPRESP" "$url")" || curl_rc=$?

  if [ "$curl_rc" -ne 0 ]; then
    echo "$mark_fail FAILED (curl rc=$curl_rc)"
    if [ -s "$TMPRESP" ]; then
      echo "Response (truncated):"
      head -n 40 "$TMPRESP"
    fi
    return 1
  fi

  if [[ "$http_code" =~ ^2 ]]; then
    echo "$mark_ok HTTP $http_code OK"
    if [ -s "$TMPRESP" ]; then
      echo "Response (truncated):"
      head -n 40 "$TMPRESP"
    fi
    return 0
  else
    echo "$mark_fail HTTP $http_code"
    if [ -s "$TMPRESP" ]; then
      echo "Response (truncated):"
      head -n 40 "$TMPRESP"
    fi
    return 1
  fi
}

failures=0

echo "Basic root connectivity (helps detect reverse-proxy TLS/HTTP issues)"
if ! check "$HOST/"; then
  failures=$((failures+1))
  echo "$mark_fail Failure at check '$HOST/'"
fi

echo "Check system health / instance"
if ! check "$HOST/api/v1/system/status"; then
  failures=$((failures+1))
  echo "$mark_fail Failure at check '$HOST/api/v1/system/status'"
fi

echo "API checks (per docs)"
if ! check "$HOST/api/v1/indexer"; then
  failures=$((failures+1))
  echo "$mark_fail Failure at check '$HOST/api/v1/indexer'"
fi

if ! check "$HOST/api/v1/indexer?page=1&size=50"; then
  failures=$((failures+1))
  echo "$mark_fail Failure at check '$HOST/api/v1/indexer?page=1&size=50'"
fi

if [ "$failures" -eq 0 ]; then
  echo "All Prowlarr checks passed."
  exit 0
else
  echo "Prowlarr checks failed: $failures failed."
  exit 3
fi
