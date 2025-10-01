# Whisparr — r0xyd0g (deployment notes)

This document describes deploying Whisparr, wiring it to the existing qBittorrent and Prowlarr instances for host `r0xyd0g` / `trillian2` and adding the Pornbay tracker (via Prowlarr).

Important: do NOT commit plaintext secrets (passwords / API keys). Use SOPS/age or another secret store and keep only encrypted files under docs/secrets.

Summary / assumptions
- Whisparr container (docker-compose) created at: containers/docker/compose/whisparr-compose.yaml
  - Container listens on port 5055 by default (can be proxied to an external hostname).
- qBittorrent (consumer / download client)
  - Public URL: https://r0xyd0g.agate.usbx.me/qbittorrent
  - Host/IP: 46.232.211.89 (or r0xyd0g.agate.usbx.me)
  - Web UI port: 17441
  - Web API base path: /api/v2
  - Username: r0xyd0g
  - Download path (remote): /home/r0xyd0g/downloads/
- Prowlarr (indexer manager)
  - Host: 192.168.1.100
  - Port: 9696
  - API base path: /api/v1
  - API key: (store encrypted / do not commit)

Goal
1) Deploy Whisparr container
2) Configure Whisparr to use qBittorrent as the download client
3) Configure Whisparr to use indexers provided by Prowlarr (preferred: add indexers in Prowlarr and point Whisparr to those Torznab feeds / or configure Whisparr to use Prowlarr directly if supported)
4) Add Pornbay indexer to Prowlarr and test end-to-end search -> download flow

Deployment steps

1) Deploy container
- From repo root:
  - cd containers/docker/compose
  - docker compose -f whisparr-compose.yaml up -d
- Verify container:
  - docker ps | grep whisparr
- If you use a reverse proxy (nginx/traefik), point a host (e.g., whisparr.example.com) to the container and/or forward port 5055.

2) Initial access
- Open browser to http://<host-or-ip>:5055 (or proxied hostname).
- Complete any first-run setup (admin user, etc). If Whisparr exposes a first-run wizard, follow it.

3) Prepare secrets (recommended)
- Create an encrypted secrets file:
  - cp docs/secrets/prowlarr-r0xyd0g.enc.yaml docs/secrets/prowlarr-r0xyd0g.yaml
  - Edit docs/secrets/prowlarr-r0xyd0g.yaml to add the Prowlarr API key (ENTER_PROWLARR_API_KEY) and any other values noted below.
  - Encrypt with sops/age and remove plaintext.
- Create a `docs/secrets/whisparr-r0xyd0g.enc.yaml` (template provided in the repo) containing:
  - QB_HOST / QB_PORT / QB_USERNAME / QB_PASSWORD
  - PROWLARR_BASE_URL / PROWLARR_API_KEY
  - (Keep plaintext only locally; encrypt before committing.)

4) Configure qBittorrent as Download Client in Whisparr
- In Whisparr UI -> Settings -> Download Clients -> Add -> qBittorrent (or "Torrent client")
  - Host: r0xyd0g.agate.usbx.me or 46.232.211.89
  - Port: 17441
  - Use HTTPS: Yes (if your reverse proxy terminates TLS)
  - API path / base path: /api/v2 (if Whisparr asks for base path)
  - Username: r0xyd0g
  - Password: (enter securely)
  - Category: (optional) set to a consistent category such as "whisparr" or "porn"
  - Test connection — if it fails:
    - Confirm network reachability from the host running Whisparr to r0xyd0g.agate.usbx.me:17441
    - If Whisparr runs on a different host/container, ensure DNS / firewall / reverse-proxy allow the connection.
    - Use the curl example locally to verify credentials (see below).

Manual API test (example)
- Login and get cookie (do NOT commit cookies):
  curl -c cookies.txt -d "username=r0xyd0g&password=<REDACTED>" -X POST "https://r0xyd0g.agate.usbx.me:17441/api/v2/auth/login"
- Check version:
  curl -b cookies.txt "https://r0xyd0g.agate.usbx.me:17441/api/v2/app/version"

5) Configure Prowlarr -> indexers and expose indexers to Whisparr
Preferred: let Prowlarr manage indexers; point Whisparr to Prowlarr-provided Torznab feeds.

A) Add Pornbay to Prowlarr (example steps)
- Login to Prowlarr (https://192.168.1.100:9696)
- Indexers -> Add -> choose "Torznab" or "Custom"
- Fill:
  - Name: Pornbay (or Pornbay <region>)
  - URL: <Pornbay Torznab/Torznab-like URL or RSS feed> (Porn / adult indexers often provide RSS; Prowlarr can ingest Torznab or RSS depending on type)
  - API Key (if required by the indexer)
  - Categories: set categories used for adult content (map to your content types)
- Save and Test the indexer in Prowlarr.
Note: Specific Pornbay torznab URL is not included here — obtain the correct Torznab or RSS feed URL from the Pornbay site or Jackett if using Jackett as a proxy. If Pornbay does not offer Torznab, use Jackett to create a Torznab endpoint and point Prowlarr at Jackett.

B) Expose the Prowlarr Torznab feed so Whisparr can use it
- In Prowlarr -> Indexers -> copy the "Torznab Feed" URL for the Pornbay indexer (or the umbrella feed)
- In Whisparr -> Settings -> Indexers / Add -> Torznab
  - Name: Pornbay (from Prowlarr)
  - URL: paste the Torznab feed copied from Prowlarr (should include API key param)
  - API Key: (if required) — use the Prowlarr API key if Whisparr needs to query Prowlarr directly; otherwise the Torznab feed URL often embeds the key.
  - Test connection

Alternative: If Whisparr supports direct Prowlarr integration:
- In Whisparr -> Settings -> Indexer Manager or Connect -> Add Prowlarr
  - Base URL: https://192.168.1.100:9696
  - API key: <enter Prowlarr API key>
  - Save/test
This will allow Whisparr to import indexer configurations managed by Prowlarr (if the app supports this feature).

6) Test end-to-end
- From Whisparr, run a search / add a release (or use 'Download' on a test result)
- Confirm a magnet/torent is sent to qBittorrent and appears in qBittorrent UI
- Confirm completed downloads are present at /home/r0xyd0g/downloads/
- If files need to be imported into another media app, configure path mapping or a shared mount/post-processing step.

7) Troubleshooting tips
- If Whisparr cannot reach qBittorrent:
  - Confirm container host DNS and network.
  - If qBittorrent is behind a reverse proxy, ensure the proxy forwards appropriate headers and paths.
  - Temporarily run a curl from the Whisparr host to test connectivity.
- If indexer results are empty:
  - Verify the indexer works in Prowlarr by running an indexer search.
  - If the indexer requires login/API tokens, ensure they're set in Prowlarr (and encrypted in repo secrets).
  - Consider using Jackett to create a Torznab endpoint if the tracker doesn't provide one.

8) Save configuration & document secrets
- After verifying, store credentials locally in encrypted files:
  - docs/secrets/whisparr-r0xyd0g.enc.yaml (SOPS-encrypted)
  - docs/secrets/prowlarr-r0xyd0g.enc.yaml (already templated)
  - docs/secrets/qbittorrent-r0xyd0g.enc.yaml (create template if needed)
- Do NOT commit plaintext.

API examples for verification
- List indexers from Prowlarr:
  curl -H "X-Api-Key: <PROWLARR_API_KEY>" "http://192.168.1.100:9696/api/v1/indexer?page=1&size=50"
- Test Prowlarr system:
  curl -H "X-Api-Key: <PROWLARR_API_KEY>" "http://192.168.1.100:9696/api/v1/system/status"

References
- docs/prowlarr-r0xyd0g.md
- docs/qbittorrent-r0xyd0g.md
- containers/docker/compose/whisparr-compose.yaml

Created: by automation (assistant). Fill secrets locally and encrypt before committing.
