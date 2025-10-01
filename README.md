# Configuration Repository

Centralized storage of server configuration, Docker stacks, VS Code setups, and disaster-recovery documentation.

## Structure

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
