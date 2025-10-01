#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/.."
LOG_DIR="$SCRIPT_DIR/logs"

mkdir -p "$LOG_DIR"

python3 "$SCRIPT_DIR/update_docs.py"
