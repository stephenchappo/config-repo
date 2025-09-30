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

1. **Sanitize service configs** under `containers/docker/configs-templates/`.  
2. **Integrate CI**:
   - Add `.pre-commit-config.yaml` with gitleaks hook.
   - Create `.github/workflows/gitleaks.yml`.
3. **Populate templates** for Ansible, Terraform, Prometheus, etc., as needed.
4. Use `scripts/collect.sh` and commit snapshots regularly.
5. For any secrets: maintain templates only, encrypt with SOPS/age, or store outside this repo.

> Keep this repository as your single source of truth for configuration and DR procedures.
