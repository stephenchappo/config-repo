#!/usr/bin/env bash
set -euo pipefail

function usage() {
  cat <<EOF
Usage: $0 --service <name> --src <src_dir> --out <out_dir>

Options:
  --service   Name of the service (for logging)
  --src       Source directory containing real config files
  --out       Output directory under configs-templates for sanitized files
  -h, --help  Show this help message
EOF
  exit 1
}

SERVICE=""
SRC=""
OUT=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --service) SERVICE="$2"; shift 2 ;;
    --src) SRC="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown argument: $1"; usage ;;
  esac
done

if [[ -z "$SERVICE" || -z "$SRC" || -z "$OUT" ]]; then
  usage
fi

echo "Sanitizing configs for service '$SERVICE'"
mkdir -p "$OUT"
cp -R "$SRC"/. "$OUT"/

# Patterns for sensitive keys
KEY_PATTERN="(?i)(token|secret|pass(word)?|api[_-]?key|client[_-]?secret|access[_-]?key)"

find "$OUT" -type f | while read -r file; do
  case "$file" in
    *.env|*.conf|*.ini)
      sed -E -i "s/((?i)[A-Z0-9_]*${KEY_PATTERN}[A-Z0-9_]*\s*=\s*).*/\1\${REDACTED}/g" "$file"
      ;;
    *.json)
      if command -v jq >/dev/null 2>&1; then
        jq 'walk(
          if type=="object" then
            with_entries(
              if (.key|test("'$KEY_PATTERN'")) then .value="REDACTED" else . end
            )
          else .
          end
        )' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
      fi
      ;;
    *.xml)
      sed -E -i \
        -e "s#(<[^>]*${KEY_PATTERN}[^>]*>)[^<]*(</[^>]+>)#\1REDACTED\2#gi" \
        -e "s#(${KEY_PATTERN}\s*=\s*\")[^\"]*(\")#\1REDACTED\2#gi" \
      "$file"
      ;;
    *)
      # Other file types left unchanged
      ;;
  esac
done

echo "Output written to $OUT"
