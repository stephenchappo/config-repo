# Home Server Docker Stack

This folder contains docker-compose files and sanitized configuration templates for your self-hosted services. Data, logs, and secrets are intentionally excluded from version control.

Directory structure:
- **compose/**: One subfolder per service, each with its `docker-compose.yml`
- **env-templates/**: Example `.env` files with placeholder values
- **configs-templates/**: Service configuration templates (no secrets)
- **scripts/**: Helper scripts (e.g., `manage-containers.sh`)
- **notes/**: Operational notes and run-throughs
- **runtime-snapshots/**: Snapshots of current Docker state (images, volumes, networks, containers)

Included services:
- `chrome-headless`  
- `cloudflared` (Cloudflare Tunnel sidecar)  
- `openvpn-as` (Access Server; configs in templates only)  
- `overseerr`, `prowlarr`, `radarr`, `sonarr`, `whisparr` (media managers)  
- `stash` (media indexer)  
- `pv2mqtt` (PV to MQTT bridge)  
- `homarr` (dashboard; see notes for exports)

## Quick Start

1. Copy example env files into runtime folders:
   ```bash
   cp env-templates/.env.example /srv/docker/.env
   cp env-templates/pv2mqtt.env.example /srv/docker/pv2mqtt/.env
   ```
2. Sync compose files to your host:
   ```bash
   rsync -a compose/ /srv/docker/
   ```
3. Bring up services:
   ```bash
   cd /srv/docker/<service>
   docker compose up -d
   ```
4. Update runtime snapshots (optional):
   ```bash
   ./scripts/manage-containers.sh snapshot-runtime
   ```

## Sensitive Data

- Never commit real `.env` files, databases, logs, or private keys.  
- Use **env-templates** and **configs-templates** with placeholder values.  
- Store secrets securely outside this repo, or encrypted with SOPS/age.

## Disaster Recovery Notes

- Recreate volumes and containers via these compose files.  
- Restore data from your backup snapshots.  
- Re-inject secrets through your secure vault or environment variables.
