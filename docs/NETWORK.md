# Network Configuration & Firewall Summary

This document captures the host’s network settings, firewall rules, and VPN configurations for disaster recovery and audit.

## 1. Host Identity

- **Hostname**  
  ```bash
  cat /etc/hostname > hostname.txt
  ```
- **Hosts file**  
  ```bash
  cat /etc/hosts > hosts.txt
  ```

## 2. DNS & Resolver

- **Resolvers**  
  ```bash
  cat /etc/resolv.conf > resolv.conf.txt
  ```
- **Netplan** (Debian/Ubuntu)  
  ```bash
  cp -a /etc/netplan/* netplan/
  ```
- **NetworkManager**  
  ```bash
  cp -a /etc/NetworkManager/system-connections/ networkmanager/
  ```

## 3. Interfaces & Routes

- **Interface status**  
  ```bash
  ip -br a > interfaces.txt
  ```
- **Routing table**  
  ```bash
  ip route show > routes.txt
  ```

## 4. Firewall Rules

Choose your firewall technology; snapshots are captured by `scripts/collect.sh`.

### UFW (Uncomplicated Firewall)
```bash
ufw status numbered > ufw-status.txt
```

### iptables
```bash
iptables-save > iptables-save.txt
```

### nftables
```bash
nft list ruleset > nft-ruleset.txt
```

## 5. VPN Configurations

Store only templates or instructions; never commit private keys.

- **WireGuard** (example):
  ```bash
  cp /etc/wireguard/wg0.conf vpn/wireguard.conf.template
  ```
- **OpenVPN**:
  ```bash
  cp /etc/openvpn/server.conf vpn/openvpn.conf.template
  ```

## 6. Reverse Proxy & DNS Tunnel

- **Cloudflare Tunnel**  
  Operational steps documented in `containers/docker/notes/CLOUDFLARE_TUNNEL_STEPS.md`.
- **Proxy vhosts**  
  Sanitize and template any NGINX/Caddy/Traefik site definitions under `services/reverse-proxy/`.

---

**Next Steps**  
After provisioning a new host:
1. Copy these files into `/etc/` (adjust paths as needed).  
2. Apply firewall rules using the above snapshots.  
3. Deploy VPN configs from templates, injecting keys via secure vault.  
4. Restart networking:  
   ```bash
   systemctl restart networking
   systemctl restart ufw || true
