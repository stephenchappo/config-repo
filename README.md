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
│   ├── update_docs.py
│   └── update_docs.sh
├── .gitignore
├── .gitleaks.toml
├── .pre-commit-config.yaml
└── README.md
```
<!-- END:STRUCTURE -->

```text
config-repo/
├── .gitignore
├── README.md                 ← this file
├── docs/
│   ├── REBUILD.md            ← rebuild guide
│   ├── INVENTORY.md          ← hardware & service inventory
│   └── NETWORK.md            ← network & firewall summary
├── scripts/
│   └── collect.sh            ← system snapshot script
├── system_snapshot/          ← timestamped snapshots (created by collect.sh)
├── containers/
│   └── docker/
│       ├── compose/          ← docker-compose files per service
│       ├── env-templates/    ← .env.example files
│       ├── configs-templates/← sanitized service config templates
│       ├── scripts/          ← helper scripts (e.g., manage-containers.sh)
│       ├── notes/            ← operational notes
│       ├── runtime-snapshots/← images/volumes/networks/containers lists
│       ├── README.md         ← Docker stack overview
│       └── USAGE_DOCKER.md   ← prompts & sync instructions
├── editors/
│   └── vscode/
│       ├── extensions.txt    ← list of installed extensions
│       └── mcp/
│           └── cline_mcp_settings.json.template
└── memory-bank/              ← existing local notes and tool docs
```

## Quick Links

- `scripts/collect.sh` Run to capture system state.
- `docs/REBUILD.md` Guide to rebuild host from scratch.
- `containers/docker/README.md` Overview of Docker service layouts.
- `containers/docker/USAGE_DOCKER.md` Routine sync & prompts library.
- `editors/vscode/extensions.txt` VS Code extensions to reinstall.
- `editors/vscode/mcp/cline_mcp_settings.json.template` Sanitized MCP settings.

## Next Steps

- [x] Sanitize service configs under `containers/docker/configs-templates/`.  
- [x] Integrate CI (pre-commit & GitHub workflows).  
- [x] Populate templates for Ansible, Terraform, Prometheus, etc.
- [ ] Create a script that scans all of the contents of the config repo, updates all of the relevant documentation including this README file, add it to a cron that runs 3x per week at 2:30am on Monday, Wednesday and Friday and then uploads all changes to git.
- [X] Use `scripts/collect.sh` and commit snapshots regularly.
- [ ] After the cron jobs have run once, verify they work and that everything has populated as we expect, no errors and no empty files.
- [ ] For any secrets: maintain templates only, encrypt with SOPS/age, or store outside this repo.

> Keep this repository as your single source of truth for configuration and DR procedures.
