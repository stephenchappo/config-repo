# Prowlarr verification snapshot — 2025-09-30 23:28:37

This snapshot captures the verification steps and API responses collected during the audit for the Prowlarr instance documented at docs/prowlarr-r0xyd0g.md.

Location
- Repo path: system_snapshot/20250930_232837/prowlarr-r0xyd0g/verification_snapshot.md
- Related doc: docs/prowlarr-r0xyd0g.md
- Secrets template: docs/secrets/prowlarr-r0xyd0g.enc.yaml (fill locally and encrypt; do NOT commit plaintext)

Commands run
- Verification script (local):
  PROWLARR_API_KEY=<redacted> PROWLARR_BASE_URL="http://192.168.1.100:9696" ./scripts/check_prowlarr.sh

- Direct curl examples (used earlier for testing):
  curl -H "X-Api-Key: <redacted>" "http://192.168.1.100:9696/api/v1/indexer"
  curl -H "X-Api-Key: <redacted>" "http://192.168.1.100:9696/api/v1/system/status"

Partial Indexers response (first ~1000 bytes captured)
[
  {
    "indexerUrls": [
      "https://www.torrentleech.org/",
      "https://www.torrentleech.cc/",
      "https://www.torrentleech.me/",
      "https://www.tleechreload.org/",
      "https://www.tlgetin.cc/"
    ],
    "legacyUrls": [
      "https://v4.torrentleech.org/"
    ],
    "definitionName": "torrentleech",
    "description": "TorrentLeech (TL) is a Private Torrent Tracker for 0DAY / GENERAL. not here _ not scene",
    "language": "en-US",
    "encoding": "Unicode (UTF-8)",
    "enable": true,
    "redirect": false,
    "supportsRss": true,
    "supportsSearch": true,
    "supportsRedirect": false,
    "supportsPagination": false,
    "appProfileId": 1,
    "protocol": "torrent",
    "privacy": "private",
    "capabilities": {
      "limitsMax": 100,
      "limitsDefault": 100,
      "categories": [
        {
          "id": 2000,
          "name": "Movies",
          "subCategories": [
            {
              "id": 2030,
              "name": "Movies/SD",

... (indexers JSON truncated; full list available from live API)
  
System / instance status (JSON)
{
  "appName": "Prowlarr",
  "instanceName": "Prowlarr",
  "version": "2.0.5.5160",
  "buildTime": "2025-08-23T21:01:59Z",
  "isDebug": false,
  "isProduction": true,
  "isAdmin": false,
  "isUserInteractive": true,
  "startupPath": "/app/prowlarr/bin",
  "appData": "/config",
  "osName": "alpine",
  "osVersion": "3.22.1",
  "isNetCore": true,
  "isLinux": true,
  "isOsx": false,
  "isWindows": false,
  "isDocker": true,
  "mode": "console",
  "branch": "master",
  "databaseType": "sqLite",
  "databaseVersion": "3.49.2",
  "authentication": "forms",
  "migrationVersion": 43,
  "urlBase": "",
  "runtimeVersion": "8.0.12",
  "runtimeName": "netcore",
  "startTime": "2025-09-30T18:34:13Z",
  "packageVersion": "2.0.5.5160",
  "packageAuthor": "[linuxserver.io](https://www.linuxserver.io/)",
  "packageUpdateMechanism": "docker"
}

Verification script output (captured)
---
GET http://192.168.1.100:9696/api/v1/indexer
HTTP 200
Response (first 1000 bytes):
[
  {
    "indexerUrls": [
      "https://www.torrentleech.org/",
      "https://www.torrentleech.cc/",
      "https://www.torrentleech.me/",
      "https://www.tleechreload.org/",
      "https://www.tlgetin.cc/"
    ],
    "legacyUrls": [
      "https://v4.torrentleech.org/"
    ],
    "definitionName": "torrentleech",
    "description": "TorrentLeech (TL) is a Private Torrent Tracker for 0DAY / GENERAL. not here _ not scene",
    "language": "en-US",
    "encoding": "Unicode (UTF-8)",
    "enable": true,
    "redirect": false,
    "supportsRss": true,
    "supportsSearch": true,
    "supportsRedirect": false,
    "supportsPagination": false,
    "appProfileId": 1,
    "protocol": "torrent",
    "privacy": "private",
    "capabilities": {
      "limitsMax": 100,
      "limitsDefault": 100,
      "categories": [
        {
          "id": 2000,
          "name": "Movies",
          "subCategories": [
            {
              "id": 2030,
              "name": "Movies/SD",

----
GET http://192.168.1.100:9696/api/v1/system/status
HTTP 200
Response (first 1000 bytes):
{
  "appName": "Prowlarr",
  "instanceName": "Prowlarr",
  "version": "2.0.5.5160",
  "buildTime": "2025-08-23T21:01:59Z",
  "isDebug": false,
  "isProduction": true,
  "isAdmin": false,
  "isUserInteractive": true,
  "startupPath": "/app/prowlarr/bin",
  "appData": "/config",
  "osName": "alpine",
  "osVersion": "3.22.1",
  "isNetCore": true,
  "isLinux": true,
  "isOsx": false,
  "isWindows": false,
  "isDocker": true,
  "mode": "console",
  "branch": "master",
  "databaseType": "sqLite",
  "databaseVersion": "3.49.2",
  "authentication": "forms",
  "migrationVersion": 43,
  "urlBase": "",
  "runtimeVersion": "8.0.12",
  "runtimeName": "netcore",
  "startTime": "2025-09-30T18:34:13Z",
  "packageVersion": "2.0.5.5160",
  "packageAuthor": "[linuxserver.io](https://www.linuxserver.io/)",
  "packageUpdateMechanism": "docker"
}
----
(Check complete)

Notes and next steps
- The API is reachable over HTTP on the local address (http://192.168.1.100:9696). If you prefer TLS, configure a reverse proxy or TLS on the host and re-run checks with HTTPS.
- To keep secrets secure, fill docs/secrets/prowlarr-r0xyd0g.enc.yaml locally and encrypt with sops/age before committing the encrypted file (or keep encrypted file in repo and plaintext out).
- To repeat this capture, run:
  PROWLARR_API_KEY=<your_api_key> PROWLARR_BASE_URL="http://192.168.1.100:9696" ./scripts/check_prowlarr.sh > system_snapshot/20250930_232837/prowlarr-r0xyd0g/check_output.txt
