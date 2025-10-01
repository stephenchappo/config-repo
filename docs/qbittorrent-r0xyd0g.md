# qBittorrent — r0xyd0g (remote host)

This file is a sanitized inventory entry created from the details you provided. Secrets (passwords/tokens) are redacted here — store them encrypted (SOPS/age, Vault) or only on the host.

Summary
- Provider / host: ultra.cc (remote host reported by user)
- Service: qBittorrent (Web UI / Web API)
- Public URL: https://r0xyd0g.agate.usbx.me/qbittorrent
- Assigned public IP: 46.232.211.89
- Web UI port: 17441
- Torrent listen port: 64128
- Username: r0xyd0g
- Password: <REDACTED — do NOT store in plaintext in this repo>
- Download path (remote): /home/r0xyd0g/downloads/
- Limits:
  - Maximum active downloads: 3
  - Maximum active uploads: 3
  - Maximum active torrents: 5
- qBittorrent Web API base path: /api/v2
- Notes:
  - The service is exposed via HTTPS (reverse proxy likely in front of qBittorrent). Confirm TLS cert path and reverse-proxy configuration on the remote host.
  - When integrating with Radarr/Prowlarr, map remote download path to the local path used by those services (see "Path mapping" below).
  - Passwords and any cookies/session files must be stored encrypted or kept only on the host and not committed to this repo.

Recommended next actions (high-level)
1. Rotate the qBittorrent password if it may have been exposed while sharing. Store the new password encrypted.
2. Test API access from a safe machine (examples below).
3. Add a sanitized entry to docs/INVENTORY.md referencing this file.
4. If you want this repo to be able to perform automated checks, create an encrypted secrets file (SOPS/age) with the credentials and add the decryption key to your secure key storage.

API / verification commands (replace <REDACTED> with secure method of providing the password — do not paste plaintext into the repo)

# Login (store cookies locally; DO NOT commit cookies.txt)
curl -c cookies.txt -d "username=r0xyd0g&password=<REDACTED>" -X POST "https://r0xyd0g.agate.usbx.me:17441/api/v2/auth/login"

# Check version (requires successful login)
curl -b cookies.txt "https://r0xyd0g.agate.usbx.me:17441/api/v2/app/version"

# List torrents
curl -b cookies.txt "https://r0xyd0g.agate.usbx.me:17441/api/v2/torrents/info"

If your Web UI is behind a reverse proxy that terminates TLS on port 443 and proxies internally to 17441, adjust the URL accordingly.

Radarr / Sonarr / Prowlarr integration notes
- Radarr / Sonarr Download Client settings:
  - Host: r0xyd0g.agate.usbx.me (or 46.232.211.89)
  - Port: 17441
  - Username: r0xyd0g
  - Password: <REDACTED>
  - Category: (create/use a consistent category, e.g., "radarr" or "movies")
  - Test connection from the UI and note any errors
- Path mapping:
  - Ensure Radarr/Sonarr/Prowlarr see the same filesystem paths as qBittorrent.
  - If Radarr/Sonarr run on a different host/container, set up a shared mount or use remote export / sync so that /home/r0xyd0g/downloads/ is accessible (or use a post-processing script to move files).

Storage and encryption recommendations
- Prefer SOPS + age for file-level encryption of secrets:
  - Create an encrypted file under docs/secrets/qbittorrent-r0xyd0g.enc.yaml (example)
  - Keep only placeholders in the repo (this file) and add a small README explaining where/how to decrypt
- Alternatives: HashiCorp Vault, AWS Secrets Manager, or a secure local non-tracked file under /home/scon/.config/config-repo/ (but do NOT commit).

Audit and verification checklist
- [ ] Rotate qBittorrent password (optional if you consider it secure)
- [ ] Create encrypted secrets file with password and store decryption key securely
- [ ] Verify API login and list endpoints using the curl commands above
- [ ] Configure Radarr/Prowlarr Download Client and run "Test" from their UIs
- [ ] Confirm path mapping and ensure Radarr/Sonarr see completed downloads where expected
- [ ] Add an entry in docs/INVENTORY.md linking to this file

Created: by automation (assistant) — sanitize carefully before sharing.
