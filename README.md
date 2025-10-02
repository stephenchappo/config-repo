# Configuration Repository

Centralized storage of server configuration, Docker stacks, VS Code setups, and disaster-recovery documentation.

## Structure
<!-- BEGIN:STRUCTURE -->
```text
├── .github
│   └── workflows
│       └── gitleaks.yml
├── containers
│   └── docker
│       ├── compose
│       │   ├── chrome-headless
│       │   │   └── docker-compose.yml
│       │   ├── cloudflared
│       │   │   └── docker-compose.yml
│       │   ├── openvpn-as
│       │   │   └── docker-compose.yml
│       │   ├── overseerr
│       │   │   └── docker-compose.yml
│       │   ├── prowlarr
│       │   │   └── docker-compose.yml
│       │   ├── pv2mqtt
│       │   │   └── docker-compose.yml
│       │   ├── radarr
│       │   │   └── docker-compose.yml
│       │   ├── sonarr
│       │   │   └── docker-compose.yml
│       │   ├── stash
│       │   │   └── docker-compose.yml
│       │   └── whisparr
│       │       └── docker-compose.yml
│       ├── configs-templates
│       │   ├── homarr
│       │   │   ├── config.json.template
│       │   │   └── README.md
│       │   ├── openvpn-as
│       │   │   ├── config.conf.template
│       │   │   └── README.md
│       │   ├── overseerr
│       │   │   ├── config.json.template
│       │   │   └── README.md
│       │   ├── prowlarr
│       │   │   ├── config.xml.template
│       │   │   └── README.md
│       │   ├── pv2mqtt
│       │   │   ├── config.json.template
│       │   │   └── README.md
│       │   ├── radarr
│       │   │   ├── config.xml.template
│       │   │   └── README.md
│       │   ├── sonarr
│       │   │   ├── config.xml.template
│       │   │   └── README.md
│       │   ├── stash
│       │   │   ├── config.xml.template
│       │   │   └── README.md
│       │   ├── whisparr
│       │   │   ├── config.xml.template
│       │   │   └── README.md
│       │   └── README.md
│       ├── env-templates
│       │   ├── .env.example
│       │   └── pv2mqtt.env.example
│       ├── notes
│       │   └── CLOUDFLARE_TUNNEL_STEPS.md
│       ├── runtime-snapshots
│       ├── scripts
│       │   ├── manage-containers.sh
│       │   └── sanitize-configs.sh
│       ├── README.md
│       └── USAGE_DOCKER.md
├── docs
│   ├── INVENTORY.md
│   ├── NETWORK.md
│   └── REBUILD.md
├── editors
│   └── vscode
│       ├── mcp
│       │   └── cline_mcp_settings.json.template
│       └── extensions.txt
├── infrastructure
│   ├── ansible
│   │   └── README.md
│   ├── monitoring
│   │   └── prometheus
│   │       └── README.md
│   └── terraform
│       └── README.md
├── logs
│   ├── collect.log
│   └── cron_collect.log
├── memory-bank
│   ├── 00_README.md
│   └── 01_CLINE_TOOLS.md
├── scripts
│   ├── logs
│   │   └── .gitkeep
│   ├── collect.sh
│   ├── install_cron.sh
│   ├── sops-decrypt-all.sh
│   ├── sops-decrypt-runner.sh
│   ├── update_docs.py
│   └── update_docs.sh
├── docs/secrets
│   ├── git.enc.json (encrypted)
│   ├── spotify.enc.json (encrypted)
│   └── ...other encrypted secrets...
├── system_snapshot/          ← timestamped snapshots (created by collect.sh)
├── .gitignore
├── .gitleaks.toml
├── .pre-commit-config.yaml
└── README.md
```
<!-- END:STRUCTURE -->

## Quick Links

- `scripts/collect.sh` Run to capture system state and (optionally) push to GitHub.
- `scripts/sops-decrypt-runner.sh` Mounts tmpfs at `/run/config-repo-secrets` and runs `scripts/sops-decrypt-all.sh` as user `scon` to decrypt secrets at runtime.
- `scripts/sops-decrypt-all.sh` Decrypts files in `docs/secrets/*.enc.*` into `/run/config-repo-secrets`, post-processes YAML/JSON/dotenv and writes small runtime files used by processes.
- `docs/REBUILD.md` Guide to rebuild host from scratch.
- `containers/docker/README.md` Overview of Docker service layouts.
- `containers/docker/USAGE_DOCKER.md` Routine sync & prompts library.
- `editors/vscode/extensions.txt` VS Code extensions to reinstall.

## Secrets handling (added 2025-10-01)

This repository uses SOPS (with Age) to store encrypted secrets under `docs/secrets/`. Plaintext secrets are never stored in the repo. Changes made on 2025-10-01:

- Added secret templates (examples only; do not commit real secrets):
  - `docs/secrets/git.env.template` — template for Git credentials
  - `docs/secrets/spotify.env.template` — template for Spotify credentials
- Encrypted the templates using SOPS and stored the encrypted files (e.g., `git.enc.json`, `spotify.enc.json`).
- Runtime decryption flow:
  1. `scripts/sops-decrypt-runner.sh` ensures `/run/config-repo-secrets` tmpfs is mounted with mode 0700 and owned by `scon`.
  2. It runs `scripts/sops-decrypt-all.sh` as user `scon` providing `SOPS_AGE_KEY_FILE` so sops can decrypt.
  3. `sops-decrypt-all.sh` decrypts the files into `/run/config-repo-secrets` and post-processes them to generate small runtime files:
     - `/run/config-repo-secrets/git_username`
     - `/run/config-repo-secrets/git_token`
     - `/run/config-repo-secrets/spotify_client_id`
     - `/run/config-repo-secrets/spotify_client_secret`
  4. Files under `/run/config-repo-secrets` are created with permissions 600 and directories 700; ownership set to `scon`.

- Notes:
  - The Age private key used by SOPS must be available to the `scon` user (recommended location: `/home/scon/.config/sops/age/age_key.txt`), protected with 600 permissions.
  - The runner and decrypt scripts are idempotent and safe to re-run; they clean previous decrypted state and re-write files.

## collect.sh changes (added 2025-10-01)

`collect.sh` was updated to:
- Resolve the repository base directory robustly.
- Source `git.env` and `spotify.env` (these files reference runtime locations).
- Automatically read runtime credentials (if present) from `/run/config-repo-secrets` and export:
  - `GITHUB_USERNAME`, `GITHUB_TOKEN`
  - `SPOTIFY_CLIENT_ID`, `SPOTIFY_CLIENT_SECRET`
- Configure a local git user identity if missing (uses the runtime username fallback).
- Perform a one-time authenticated push using the token when available (embedded-URL push), otherwise fall back to a standard `git push`.
- Log all operations to `logs/collect.log` and place snapshots into `system_snapshot/<timestamp>/`.

## What I did today (2025-10-01)

- Implemented secure secrets templates and encrypted them with SOPS.
- Added `scripts/sops-decrypt-all.sh` to decrypt repo secrets into a secured tmpfs and post-process them into runtime files.
- Added `scripts/sops-decrypt-runner.sh` (systemd/runner friendly) to orchestrate mount and decryption as user `scon`.
- Updated `scripts/collect.sh` to read runtime secret files and use them for authenticated git pushes.
- Created runtime `git.env` and `spotify.env` files that point at `/run/config-repo-secrets/...` (these are safe, small, and non-secret).
- Restored script permissions and fixed issues found during testing.
- Verified runner + decryption flow and validated pushing commits to your GitHub account (performed authenticated push; resolved remote divergence with an authenticated fetch/rebase and push).
- Committed and pushed the changes to the repo (branch `main`).

## How to run

1. Decrypt secrets into tmpfs (recommended runner):
   sudo bash scripts/sops-decrypt-runner.sh

2. Run the snapshot script (as root):
   sudo bash scripts/collect.sh

3. Verify logs:
   tail -n 200 logs/collect.log

4. Cleanup (optional): unmount tmpfs after you're done:
   sudo umount /run/config-repo-secrets && sudo rmdir /run/config-repo-secrets

## Outstanding / optional improvements

- Add an automated cron/systemd timer to run the documentation update and snapshot workflow.
- Harden runner to automatically remove runtime plaintext files after push (if desired).
- Improve error handling in musical preferences scripts (they currently require LikedSongs.csv and pandas).
- Add CI checks to ensure encrypted files are not accidentally committed in plaintext.

## Next steps recommended

- Confirm the runtime secrets remain in `/run/config-repo-secrets` across reboots or ensure the systemd runner is enabled.
- Test the full flow from decryption -> snapshot -> push via the runner and collect script (done interactively today).
- If you want, I can create the systemd unit and enable a timer/cron entry for you.

> Keep this repository as your single source of truth for configuration and DR procedures.
