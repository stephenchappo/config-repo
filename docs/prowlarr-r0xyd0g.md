# Prowlarr — r0xyd0g (remote host)

This file is a sanitized inventory entry created to mirror the existing qBittorrent entry for the same host. Secrets (API keys/tokens) are redacted here — store them encrypted (SOPS/age, Vault) or only on the host.

Summary
- Provider / host: trillian2
- Service: Prowlarr (Indexer manager / API)
- Assigned public IP: 192.168.1.100
- Web UI port: 9696
- API key: <REDACTED — do NOT store in plaintext in this repo>
- API base path: /api/v1
- Encrypted secrets file: docs/secrets/prowlarr-r0xyd0g.enc.yaml (fill locally, encrypt with sops/age; do NOT commit plaintext)
- Notes:
  - The service is exposed via HTTPS (reverse proxy likely in front of Prowlarr). Confirm TLS cert path and reverse-proxy configuration on the remote host.
  - This document was created with reference to docs/qbittorrent-r0xyd0g.md — see that file for the qBittorrent service details and path mapping notes.
  - Prowlarr uses an API key (not username/password) for automation. Keep the API key encrypted and only provide it to services that require it (Radarr/Sonarr/Plex hooks, CI scripts, etc).
  - Typical Prowlarr usage:
    - Manage indexers (Torznab/Jackett-like endpoints)
    - Provide indexer endpoints to Radarr/Sonarr/Prowlarr-aware services
    - Optionally host an indexer proxy for local apps

Recommended next actions (high-level)
1. Create an encrypted secrets file containing the Prowlarr API key and any other credentials.
2. Test API access from a safe machine using the examples below.
3. Add a sanitized entry to docs/INVENTORY.md referencing this file.
4. If desired, script automated checks that use the encrypted API key to verify service health and indexer status.

API / verification commands (replace <REDACTED> with secure method of providing the API key — do not paste plaintext into the repo)

# Basic API check (replace host/port if proxied)
curl -H "X-Api-Key: <REDACTED>" "192.168.1.100:9696/api/v1/indexer"

# Example: list indexers (may require different endpoint depending on Prowlarr version)
curl -H "X-Api-Key: <REDACTED>" "192.168.1.100:9696/api/v1/indexer?page=1&size=50"

# Example: check system health / instance (consult upstream docs if endpoint differs)
curl -H "X-Api-Key: <REDACTED>" "192.168.1.100:9696/api/v1/system/status"

Notes on integration with Radarr / Sonarr / qBittorrent
- Prowlarr provides indexers that Radarr/Sonarr use to search for releases. It is not a download client — Radarr/Sonarr will still send downloads to qBittorrent (or other download clients).
- When wiring up Radarr/Sonarr to use indexers managed by Prowlarr:
  - In Radarr/Sonarr, add indexers using the Torznab URL exposed by Prowlarr (see Prowlarr's "Indexer" -> "Copy Torznab Feed" for the correct URL).
  - If Radarr/Sonarr run on different hosts/containers, ensure they can reach 192.168.1.100:9696 (or the proxied path).
  - Provide the Prowlarr API key to Radarr/Sonarr where required to automatically add indexers (or use manual copy/paste).
- Path mapping:
  - Ensure qBittorrent and consumer apps (Radarr/Sonarr) agree on download locations. See docs/qbittorrent-r0xyd0g.md for qBittorrent's download path (/home/r0xyd0g/downloads/).
  - If Radarr/Sonarr run elsewhere, create a shared mount or sync mechanism so that completed downloads are available at the expected path, or use a post-processing/move step.

Storage and encryption recommendations
- Prefer SOPS + age for file-level encryption of secrets:
  - Create an encrypted file under docs/secrets/prowlarr-r0xyd0g.enc.yaml (example)
  - Keep only placeholders in the repo and add a small README explaining where/how to decrypt
- Alternatives: HashiCorp Vault, AWS Secrets Manager, or a secure local non-tracked file under /home/scon/.config/config-repo/ (but do NOT commit).

Audit and verification checklist
- [ ] Create encrypted secrets file with Prowlarr API key and store decryption key securely
      - Status: TEMPLATE created at docs/secrets/prowlarr-r0xyd0g.enc.yaml. Fill locally and encrypt with sops/age. I did NOT commit plaintext.
- [ ] Verify API access using the curl commands above
      - Status: Attempted from this machine using the provided API key. Result: connection refused (service not reachable on 192.168.1.100:9696). See scripts/check_prowlarr.sh for a reusable local check you can run after ensuring network/proxy is correct or after decrypting secrets locally.
- [x] Add an entry in docs/INVENTORY.md linking to this file
      - Status: Done (docs/INVENTORY.md updated to include docs/prowlarr-r0xyd0g.md).
- [ ] Configure Radarr/Sonarr to use indexers provided by Prowlarr and test indexer searches
      - Status: Manual configuration required. Steps:
        1) In Prowlarr -> Indexers -> Copy Torznab Feed (or use the Torznab URL shown for each indexer).
        2) In Radarr/Sonarr -> Indexers -> Add -> Torznab -> paste URL and set API key.
        3) Test connection from Radarr/Sonarr UI and run a test search.
        4) If Radarr/Sonarr run on different hosts, ensure they can reach the Prowlarr URL (network/proxy/firewall).
- [x] Confirm path mapping between qBittorrent and any consumers so completed downloads are found
      - Status: Confirmed qBittorrent download path from docs/qbittorrent-r0xyd0g.md: /home/r0xyd0g/downloads/. Ensure consumers see same path or implement a shared mount / sync / post-processing move.
- [x] (Optional) Add automated health/indexer-check scripts that use the encrypted API key
      - Status: Done — created scripts/check_prowlarr.sh. Usage:
        - Export PROWLARR_API_KEY and run: PROWLARR_API_KEY=your_key ./scripts/check_prowlarr.sh
        - Or, if you encrypted the secrets with sops and have sops+yq installed locally, run: ./scripts/check_prowlarr.sh

References
- Related service entry: docs/qbittorrent-r0xyd0g.md
- Prowlarr official docs: https://wiki.servarr.com/prowlarr (consult for exact API endpoints and version-specific differences)
- Verification snapshot: system_snapshot/20250930_232837/prowlarr-r0xyd0g/verification_snapshot.md

Created: by automation (assistant) — sanitize carefully before sharing.
