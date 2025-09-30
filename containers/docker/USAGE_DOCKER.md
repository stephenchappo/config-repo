# Docker Usage & Prompts Library

This document helps you keep your Docker configs in sync and up to date. Use the prompts below to automate routine maintenance.

## Routine Sync Steps

1. **Inventory services**  
   Diff live `/srv/docker` vs. repo `containers/docker/compose/`:  
   ```bash
   diff -r /srv/docker/containers/docker/compose/ /srv/docker
   ```
2. **Sync compose files**  
   For each service folder:  
   ```bash
   rsync -au /srv/docker/<service>/docker-compose.yml containers/docker/compose/<service>/
   ```
3. **Redact `.env` files**  
   ```bash
   cp /srv/docker/.env containers/docker/env-templates/.env.example
   sed -E 's/=.*/=<REPLACE_ME>/' containers/docker/env-templates/.env.example
   ```
4. **Redact `pv2mqtt` env**  
   ```bash
   cp /srv/docker/pv2mqtt/.env containers/docker/env-templates/pv2mqtt.env.example
   sed -E 's/=.*/=<REPLACE_ME>/' containers/docker/env-templates/pv2mqtt.env.example
   ```
5. **Sanitize app configs**  
   ```bash
   for svc in overseerr prowlarr radarr sonarr whisparr stash; do
     sed -E 's|<secret>.*</secret>|<secret>REPLACE_ME</secret>|g' \
       /srv/docker/$svc/config/config.xml \
       > containers/docker/configs-templates/$svc/config.xml.template
   done
   ```
6. **Update runtime snapshots**  
   ```bash
   docker images > containers/docker/runtime-snapshots/images.txt
   docker volume ls > containers/docker/runtime-snapshots/volumes.txt
   docker network ls > containers/docker/runtime-snapshots/networks.txt
   docker ps -a > containers/docker/runtime-snapshots/containers.txt
   ```

7. **Sanitize service configs**  
```bash
containers/docker/scripts/sanitize-configs.sh \
  --service <service> \
  --src /srv/docker/<service>/config \
  --out containers/docker/configs-templates/<service>
```

## Prompts Library

Toggle to Act mode and run these prompts in Cline:

- “List `/srv/docker` recursively and report new or removed services vs. `containers/docker/compose`.”
- “Sync updated `docker-compose.yml` files from `/srv/docker/*/docker-compose.yml` into `containers/docker/compose/`.”
- “Generate updated `.env.example` for each service by redacting values in `/srv/docker/*.env`.”
- “Sanitize primary config files for overseerr, prowlarr, radarr, sonarr, whisparr, stash into `.template` files.”
- “Run Docker CLI snapshot: images, volumes, networks, containers into `runtime-snapshots/`.”
- “Validate `.gitignore` excludes all stateful files under `/srv/docker`.”
- “Create or update `scripts/snapshot-runtime.sh` to run all snapshot commands in one go.”

Use these regularly to keep your Docker configs versioned safely and up to date.
