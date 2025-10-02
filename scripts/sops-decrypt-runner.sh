#!/usr/bin/env bash
# sops-decrypt-runner.sh
# Purpose:
# - Ensure tmpfs mount exists at /run/config-repo-secrets (create or remount if needed)
# - Run the repo decrypt script as the 'scon' user while providing sops the correct key environment
# - Fix ownership & permissions of the decrypted files
#
# Run this as root (systemd unit will run it as root). The actual sops decrypt runs as 'scon'.
set -euo pipefail

REPO_ROOT="/home/scon/config-repo"
TARGET_DIR="/run/config-repo-secrets"
SOPS_AGE_KEY="/home/scon/.config/sops/age/age_key.txt"
SUSER="scon"

echo "[sops-runner] Starting at $(date -Iseconds)"

# Ensure tmpfs mount exists; if already mounted, force a remount with correct options.
if mountpoint -q "$TARGET_DIR"; then
  echo "[sops-runner] $TARGET_DIR already mounted; remounting with uid=1000, gid=1000"
  mount -o remount,uid=1000,gid=1000 "$TARGET_DIR"
else
  echo "[sops-runner] Mounting tmpfs at $TARGET_DIR with uid=1000, gid=1000"
  mkdir -p "$TARGET_DIR"
  mount -t tmpfs -o mode=0700,uid=1000,gid=1000 tmpfs "$TARGET_DIR"
fi

# Ensure base permissions on mount point.
chmod 700 "$TARGET_DIR" || true
chown 1000:1000 "$TARGET_DIR" || true

# Verify sops key exists.
if [ ! -f "$SOPS_AGE_KEY" ]; then
  echo "[sops-runner] ERROR: SOPS age key not found at $SOPS_AGE_KEY" >&2
  exit 2
fi

# Run the repo decrypt script as the user 'scon', providing correct environment.
echo "[sops-runner] Running decrypt script as user $SUSER"
if command -v runuser >/dev/null 2>&1; then
  runuser -u "$SUSER" -- env SOPS_AGE_KEY_FILE="$SOPS_AGE_KEY" HOME="/home/$SUSER" bash -lc "$REPO_ROOT/scripts/sops-decrypt-all.sh"
else
  sudo -u "$SUSER" env SOPS_AGE_KEY_FILE="$SOPS_AGE_KEY" HOME="/home/$SUSER" bash -lc "$REPO_ROOT/scripts/sops-decrypt-all.sh"
fi

# Fix ownership and permissions under the mount.
echo "[sops-runner] Fixing ownership and permissions under $TARGET_DIR"
chown -R 1000:1000 "$TARGET_DIR" || true
find "$TARGET_DIR" -type d -exec chmod 700 {} \; || true
find "$TARGET_DIR" -type f -exec chmod 600 {} \; || true

echo "[sops-runner] Completed at $(date -Iseconds)"
exit 0
