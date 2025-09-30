# Disaster Recovery & Rebuild Guide

This document outlines the step-by-step process to rebuild the machine from scratch using this repository.

## Prerequisites

- Boot a compatible Linux distribution (matching `/etc/os-release`)
- Clone this repository:
  ```
  git clone git@github.com:your-org/config-repo.git
  cd config-repo
  ```
- Install prerequisites: Docker, Docker Compose v2, APT, snap, flatpak, Git, bash

## 1. Restore System & Package State

1. **APT sources & keys**  
   Copy `/system/os/sources.list.d/` and `/system/os/sources.list` into `/etc/apt/`, then:
   ```bash
   apt-get update
   apt-get install -y $(awk '$2=="install"{print $1}' system/os/dpkg-selections.txt)
   ```
2. **Snaps & Flatpaks**  
   ```bash
   snap install $(awk 'NR>1{print $1}' system/os/snaps.txt)
   flatpak install --noninteractive flathub $(awk 'NR>1{print $1}' system/os/flatpaks.txt)
   ```
3. **Kernel & sysctl**  
   Copy `system/os/sysctl.conf` and `sysctl.d/` → `/etc/sysctl.d/` then:
   ```bash
   sysctl --system
   ```

## 2. Network & Firewall

1. Copy `network/hostname.txt` → `/etc/hostname`  
2. Copy `network/hosts` → `/etc/hosts`  
3. Apply Netplan/NetworkManager profiles from `network/netplan/` or `network/NetworkManager/`  
4. Import firewall rules:
   ```bash
   ufw reset && ufw enable && ufw status numbered < network/ufw/ufw-status.txt
   iptables-restore < network/firewall/iptables-save.txt
   nft -f network/firewall/nft-ruleset.txt
   ```

## 3. Systemd & Schedulers

1. Enable units from `system/systemd/systemd-enabled-units.txt`:
   ```bash
   xargs -a system/systemd/systemd-enabled-units.txt systemctl enable
   ```
2. Deploy overrides from `system/systemd/...` to `/etc/systemd/system/`  
3. Install cron jobs:
   ```bash
   crontab system/systemd/cron-root.txt
   for f in system/systemd/cron-*.txt; do crontab -u "${f#*cron-}" "$f"; done
   ```

## 4. Deploy Containers

Follow the instructions in `containers/docker/README.md`:
- Copy env templates
- Sync compose files
- `docker compose up -d`

## 5. Configure Users & Editors

1. Copy sanitized dotfiles from `system/users/scon/` → home directories  
2. Install VS Code, then:
   ```bash
   code --install-extension $(cat editors/vscode/extensions.txt)
   ```
3. Copy sanitized settings:
   ```
   ~/.config/Code/User/settings.json ← editors/vscode/settings.json.template
   ```

## 6. Restore MCP Server

1. Copy `editors/vscode/mcp/cline_mcp_settings.json.template` → your global MCP config  
2. Provide PAT via `${input:github_token}` prompt or environment variable.

---

Once complete, verify services and run `scripts/collect.sh` to confirm snapshots.
