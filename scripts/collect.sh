#!/usr/bin/env bash
# collect.sh – snapshot system and musical preferences with logging and git upload
# Usage: sudo bash scripts/collect.sh

set -euo pipefail
if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root" >&2
  exit 1
fi

BASEDIR="$(dirname "$0")/.."
source "$BASEDIR/../git.env"
source "$BASEDIR/../spotify.env"
OUTDIR="$BASEDIR/system_snapshot/$(date +%Y%m%d_%H%M%S)"
LOGDIR="$BASEDIR/logs"
LOGFILE="$LOGDIR/collect.log"
mkdir -p "$OUTDIR" "$LOGDIR"

echo "[$(date)] Starting snapshot" | tee -a "$LOGFILE"

# helper to run a command, capture failure, and warn if output file empty
run_capture() {
  local cmd="$1"
  local dest="$2"
  echo "[$(date)] Running: $cmd" | tee -a "$LOGFILE"
  if ! eval "$cmd" 2>>"$LOGFILE"; then
    echo "[$(date)] ERROR: command failed: $cmd" | tee -a "$LOGFILE"
  fi
  if [[ -e "$dest" && ! -s "$dest" ]]; then
    echo "[$(date)] WARNING: empty output: $dest" | tee -a "$LOGFILE"
  fi
}

run_capture "cat /etc/os-release > \"$OUTDIR/os-release.txt\"" "$OUTDIR/os-release.txt"
run_capture "dpkg --get-selections > \"$OUTDIR/dpkg-selections.txt\"" "$OUTDIR/dpkg-selections.txt"
run_capture "apt-mark showmanual > \"$OUTDIR/apt-manual.txt\"" "$OUTDIR/apt-manual.txt"

# firewall rules
if command -v ufw &> /dev/null; then
  run_capture "ufw status numbered > \"$OUTDIR/ufw-status.txt\"" "$OUTDIR/ufw-status.txt"
else
  echo "[$(date)] INFO: ufw not installed or disabled" | tee -a "$LOGFILE"
  echo "ufw not installed" > "$OUTDIR/ufw-status.txt"
fi
run_capture "iptables-save > \"$OUTDIR/iptables-save.txt\"" "$OUTDIR/iptables-save.txt"
run_capture "nft list ruleset > \"$OUTDIR/nft-ruleset.txt\"" "$OUTDIR/nft-ruleset.txt"

# Spotify environment and Python dependencies
source "$BASEDIR/../spotify.env"
export SNAPSHOT_OUTDIR="$OUTDIR"
run_capture "apt-get update && apt-get install -y python3-pip" "/dev/null"
run_capture "pip3 install spotipy pandas" "/dev/null"

# musical preferences
run_capture "apt-get update && apt-get install -y python3-pandas" "/dev/null"
run_capture "python3 \"$BASEDIR/musical tastes/scripts/musical_preferences.py\" > \"$OUTDIR/musical_preferences.txt\"" "$OUTDIR/musical_preferences.txt"

echo "[$(date)] Committing snapshot to git" | tee -a "$LOGFILE"
pushd "$BASEDIR" > /dev/null
if [[ -n "${GITHUB_TOKEN-}" ]]; then
  git remote set-url origin "https://${GITHUB_TOKEN}@github.com/scon/config-repo.git"
fi
if ! git commit -m "Automated snapshot $(date +%Y-%m-%d_%H:%M)" >>"$LOGFILE" 2>&1; then
  echo "[$(date)] INFO: nothing to commit" | tee -a "$LOGFILE"
fi
git push origin main >>"$LOGFILE" 2>&1 || echo "[$(date)] ERROR: git push failed" | tee -a "$LOGFILE"
popd > /dev/null

echo "[$(date)] Snapshot complete: $OUTDIR" | tee -a "$LOGFILE"
