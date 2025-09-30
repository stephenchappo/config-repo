#!/usr/bin/env bash
# collect.sh – snapshot key system and service configurations
# Usage: bash scripts/collect.sh

set -euo pipefail
OUTDIR="$(dirname "$0")/../system_snapshot/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"

echo "Collecting OS release..."
cat /etc/os-release > "$OUTDIR/os-release.txt"

echo "Collecting APT sources and pins..."
cp -a /etc/apt/sources.list* "$OUTDIR/" 2>/dev/null || true
cp -a /etc/apt/preferences.d "$OUTDIR/" 2>/dev/null || true

echo "Collecting installed packages..."
dpkg --get-selections > "$OUTDIR/dpkg-selections.txt"
apt-mark showmanual > "$OUTDIR/apt-manual.txt"

echo "Collecting snaps and flatpaks..."
snap list > "$OUTDIR/snaps.txt" 2>/dev/null || true
flatpak list --app > "$OUTDIR/flatpaks.txt" 2>/dev/null || true

echo "Collecting kernel & sysctl..."
cat /etc/sysctl.conf > "$OUTDIR/sysctl.conf" 2>/dev/null || true
cp -a /etc/sysctl.d "$OUTDIR/" 2>/dev/null || true
cp -a /etc/modules-load.d "$OUTDIR/" 2>/dev/null || true

echo "Collecting time & locale..."
timedatectl status > "$OUTDIR/timedatectl.txt"
localectl status > "$OUTDIR/localectl.txt"

echo "Collecting systemd unit files..."
systemctl list-unit-files --state=enabled > "$OUTDIR/systemd-enabled-units.txt"
cp -a /etc/systemd/system "$OUTDIR/systemd-overrides" 2>/dev/null || true

echo "Collecting cron jobs..."
crontab -l > "$OUTDIR/cron-root.txt" 2>/dev/null || true
for user in $(cut -f1 -d: /etc/passwd); do
  crontab -l -u "$user" > "$OUTDIR/cron-$user.txt" 2>/dev/null || true
done

echo "Collecting firewall rules..."
if command -v ufw &> /dev/null; then
  if ! ufw status numbered > "$OUTDIR/ufw-status.txt" 2>&1; then
    echo "ufw status failed or needs root privileges" > "$OUTDIR/ufw-status.txt"
  fi
else
  echo "ufw not installed or disabled" > "$OUTDIR/ufw-status.txt"
fi
iptables-save > "$OUTDIR/iptables-save.txt" 2>/dev/null || true
nft list ruleset > "$OUTDIR/nft-ruleset.txt" 2>/dev/null || true

echo "Collecting Docker runtime snapshots..."
docker images > "$OUTDIR/docker-images.txt" 2>/dev/null || true
docker volume ls > "$OUTDIR/docker-volumes.txt" 2>/dev/null || true
docker network ls > "$OUTDIR/docker-networks.txt" 2>/dev/null || true
docker ps -a > "$OUTDIR/docker-containers.txt" 2>/dev/null || true

echo "System snapshot complete: $OUTDIR"
