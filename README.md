# Configuration Repository

Centralized storage of server configuration, Docker stacks, VS Code setups, and disaster-recovery documentation.

## Recent work (Whisparr / qBittorrent / Prowlarr)

Summary of what I did for you in this repo during the current session:
- Created a Whisparr docker-compose file: `containers/docker/compose/whisparr-compose.yaml`
- Added a secrets template for Whisparr: `docs/secrets/whisparr-r0xyd0g.enc.yaml` (TEMPLATE — fill locally then encrypt)
- Created operational notes: `docs/whisparr-r0xyd0g.md` explaining deployment and integration steps
- Deployed a Whisparr container on the host (listening on port 6969)
- Created a Whisparr API key (used to call the API for automation)
- Programmatically added qBittorrent as a Download Client in Whisparr (attempted). The attempt failed initially when using the wrong JSON shape; the POST must follow Whisparr's client ConfigContract. I then inspected the available definitions and adjusted the approach.
- Queried Prowlarr with the API key and retrieved existing indexer metadata (confirmed that Prowlarr is reachable at http://192.168.1.100:9696 and that indexers exist).
- Stopped at final wiring: Whisparr -> Prowlarr integration and adding the Pornbay torznab feed remain to be completed.

Current known endpoints & credentials (do NOT commit these in plaintext — store encrypted)
- qBittorrent:
  - Public URL: https://r0xyd0g.agate.usbx.me (or 46.232.211.89)
  - Web UI port: 17441
  - API base path: /api/v2
  - Username: r0xyd0g
  - Password: (you provided; store encrypted)
  - Download path (remote): /home/r0xyd0g/downloads/
- Prowlarr:
  - Base URL: http://192.168.1.100:9696
  - API key: (you provided; store encrypted)
- Whisparr:
  - Local URL (deployed): http://127.0.0.1:6969
  - API key created for automation: (stored by user; not committed)
  - Docker compose: containers/docker/compose/whisparr-compose.yaml
  - Secrets template: docs/secrets/whisparr-r0xyd0g.enc.yaml

What worked
- Whisparr container image and service launched and responded on port 6969.
- Whisparr system status API returned appName: "Whisparr" and version information.
- Prowlarr API responded; indexer metadata was retrievable via the API (indexers exist and support RSS/Torznab).
- I successfully verified that Whisparr's API can be called using the API key.

What still needs doing (next steps)
1. Finalize Whisparr -> Prowlarr integration (recommended)
   - Option A (recommended): Configure Whisparr to use Prowlarr by adding the Prowlarr base URL + API key in Whisparr's Indexer Manager. This lets Whisparr import indexers managed by Prowlarr.
     - Base URL to use in Whisparr: http://192.168.1.100:9696 (NO trailing slash)
     - API Key: Prowlarr API key (encrypted locally)
   - Option B: Add a single Torznab feed directly to Whisparr (paste the exact "Copy Torznab Feed" URL from Prowlarr for the Pornbay indexer).
2. Add the Pornbay indexer
   - If Pornbay provides a Torznab URL, paste the full Torznab feed into Whisparr (or add it in Prowlarr and let Whisparr import it).
   - If Pornbay does not provide a Torznab feed, use Jackett as a proxy to produce a Torznab endpoint and add that feed to Prowlarr/Whisparr.
3. Verify qBittorrent client configuration in Whisparr
   - If you use a reverse-proxy path (e.g., https://r0xyd0g.agate.usbx.me/qbittorrent) set the Whisparr qBittorrent "Base URL" field to `/qbittorrent` and enable SSL.
   - If qBittorrent is served directly on port 17441, leave Base URL blank and enable SSL if TLS is used.
   - Run the Whisparr "Test" connection for qBittorrent. If it fails, run the curl tests below from the Whisparr host.
4. Test end-to-end
   - From Whisparr: run a search or a manual download test to ensure the magnet/torrent is sent to qBittorrent and appears in the qBittorrent UI and in the downloads folder.

Debugging commands (run from the host running Whisparr)
- Test Prowlarr Torznab feed (replace COPY_FEED_URL with the actual feed Prowlarr provides):
  curl -v "COPY_FEED_URL" -H "X-Api-Key: <PROWLARR_API_KEY>"
  Expect: XML / RSS response.
- Test qBittorrent login (proxy path example):
  curl -k -c /tmp/qb_cookies -d "username=r0xyd0g&password=<QB_PASSWORD>" -X POST "https://r0xyd0g.agate.usbx.me/qbittorrent/api/v2/auth/login"
  curl -b /tmp/qb_cookies "https://r0xyd0g.agate.usbx.me/qbittorrent/api/v2/app/version"
- Whisparr API calls (example):
  curl -H "X-Api-Key: <WHISPARR_API_KEY>" "http://127.0.0.1:6969/api/v3/system/status"

Security / secret handling
- Do NOT commit API keys or passwords. Use the templates in `docs/secrets/` and encrypt them with sops/age locally.
- Example templates created: `docs/secrets/whisparr-r0xyd0g.enc.yaml` and `docs/secrets/prowlarr-r0xyd0g.enc.yaml`.

Files added/modified
- Added: containers/docker/compose/whisparr-compose.yaml
- Added: docs/whisparr-r0xyd0g.md
- Added: docs/secrets/whisparr-r0xyd0g.enc.yaml

Proposed next immediate actions (pick one)
- I. I will add the Prowlarr integration to Whisparr now (use base URL http://192.168.1.100:9696 and the Prowlarr API key already provided). — I can do this programmatically and then import indexers.
- II. I will add a specific Torznab feed (paste the Prowlarr "Copy Torznab Feed" URL for Pornbay) directly into Whisparr.
- III. I will provide step-by-step UI instructions if you'd rather do it yourself.
- IV. Stop and document everything for handover.

If you'd like me to continue and "wire" Prowlarr -> Whisparr now, reply "I" (I'll configure it using the existing Prowlarr API key). If you prefer to supply the Torznab feed URL for Pornbay and have me add that directly, reply "II" and paste the feed URL. If you'd rather do it yourself, reply "III" and I'll add short UI steps.

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
