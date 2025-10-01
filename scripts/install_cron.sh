#!/usr/bin/env bash
set -euo pipefail

# Installs cron job to run update_docs.sh at 2:30am on Mon, Wed, Fri

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CRON_CMD="$SCRIPT_DIR/update_docs.sh >> \"$SCRIPT_DIR/logs/update_docs.log\" 2>&1"
CRON_SCHEDULE="30 2 * * 1,3,5"

# Exit if the cron job already exists
crontab -l 2>/dev/null | grep -F -- "$CRON_CMD" >/dev/null && exit 0

# Install the cron job
( crontab -l 2>/dev/null; echo "$CRON_SCHEDULE $CRON_CMD" ) | crontab -

echo "Cron job installed: $CRON_SCHEDULE $CRON_CMD"
