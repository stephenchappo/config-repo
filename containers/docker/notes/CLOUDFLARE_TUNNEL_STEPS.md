# Cloudflare Tunnel + Access for Overseerr (overseerr.fake-dom.com)

This guide creates a Cloudflare Tunnel secured by Cloudflare Access (Google as IdP) for Overseerr. Your Overseerr container is no longer exposed on a host port; access is via https://overseerr.fake-dom.com with Google login.

Prerequisites
- Cloudflare account and Zero Trust enabled (free plan is fine).
- fake-dom.com added to Cloudflare DNS and status is “Active”.
- Team domain set in Zero Trust (e.g., YOURTEAM.cloudflareaccess.com).
- Docker Compose files already updated:
  - overseerr has no `ports` mapping (internal-only).
  - cloudflared service added (uses `CLOUDFLARED_TUNNEL_TOKEN`).
  - srv/docker/.env contains:
    - OVERSEERR_DOMAIN=overseerr.fake-dom.com
    - CLOUDFLARED_TUNNEL_TOKEN= (to be filled)

1) Configure Google as an Identity Provider (one-time)
A. Cloudflare
- Zero Trust → Settings → Authentication → Login Methods → Add new → Google.
- Copy the “Redirect URL” Cloudflare shows (e.g., https://YOURTEAM.cloudflareaccess.com/cdn-cgi/access/callback).

B. Google Cloud Console
- Create/select a project → APIs & Services → OAuth consent screen:
  - User type: External
  - Add Authorized domain: fake-dom.com (verify domain if prompted).
- Credentials → Create Credentials → OAuth client ID (Web application):
  - Authorized redirect URI: paste the Cloudflare Redirect URL from above.
- Copy the Client ID and Client Secret back into the Google login method in Cloudflare and Save.

2) Create the Cloudflare Tunnel and get the Token
- Zero Trust → Networks → Tunnels → Create a tunnel.
- Name it (e.g., homelab-overseerr).
- Choose the “Use a token”/Docker connector flow.
- Copy the displayed TUNNEL TOKEN.

3) Add the token to your server
- Edit srv/docker/.env and set:
  CLOUDFLARED_TUNNEL_TOKEN=PASTE_YOUR_TOKEN_HERE
- Ensure OVERSEERR_DOMAIN=overseerr.fake-dom.com is present.

4) Publish Overseerr via the Tunnel
- In the tunnel details → Public Hostnames → Add:
  - Hostname: overseerr.fake-dom.com
  - Type: HTTP
  - URL: http://overseerr:5055
- Save. Cloudflare will create the proxied DNS record automatically (no A/AAAA record needed from you).

5) Protect the hostname with Cloudflare Access
- Zero Trust → Access → Applications → Add application → Self-hosted.
  - Application domain: overseerr.fake-dom.com
  - Session duration: e.g., 24 hours
  - Login methods: select Google
  - Policy: Allow → Include → your Google email(s) (e.g., you@example.com).
  - Optional: Require MFA or device posture checks.
- Save.

6) Deploy on your server
From the host running docker-compose:
- cd /srv/docker
- docker compose up -d --force-recreate overseerr cloudflared

7) Test
- Visit https://overseerr.fake-dom.com
  - You should first hit Cloudflare Access and authenticate with Google.
  - After login, Overseerr should load.
- In Overseerr → Settings → General:
  - Application URL: https://overseerr.fake-dom.com
  - Save.

8) Cutover and Hardening
- Remove the router/NAT port-forward for 5055 (Overseerr is now only reachable via the tunnel).
- Optional in Cloudflare:
  - WAF rules, Bot Fight Mode, and/or rate limiting for overseerr.fake-dom.com.
  - Restrict by country/ASN if desired.
  - Enable HTTP/2/3; enable HSTS once you confirm HTTPS is stable.

Troubleshooting
- Tunnel not connecting:
  - docker logs cloudflared --tail=200
  - Ensure CLOUDFLARED_TUNNEL_TOKEN is correct and no extraneous characters.
- Hostname 502/Not reachable:
  - Confirm the Public Hostname URL is http://overseerr:5055 (container name + internal port).
  - Ensure overseerr container is running without a published host port.
- Access login loop or 403:
  - Confirm Access app domain matches exactly overseerr.fake-dom.com.
  - Verify your Google email is included in the Allow policy.
  - Check that Google IdP is configured with the exact Cloudflare redirect URL.
- DNS issues:
  - Cloudflare should auto-create the proxied record for the tunnel. Ensure the record is proxied (orange cloud).

Next actions
- After you paste the token into srv/docker/.env, (re)deploy: docker compose up -d --force-recreate overseerr cloudflared
- Once verified, remove the old router port-forward for 5055.
- Consider moving Radarr/Sonarr/Prowlarr/Homarr behind the tunnel next (similar Public Hostnames) or at least bind them to LAN-only on the host.
