#!/usr/bin/env bash
# Decrypt all SOPS-encrypted files in the repo into a tmpfs location.
# - Finds files matching docs/secrets/*.enc.(yaml|yml|json)
# - Decrypts them to /run/config-repo-secrets maintaining relative paths
# - Ensures tight permissions (700 on dirs, 600 on files)
#
# Usage:
#   sudo /home/scon/config-repo/scripts/sops-decrypt-all.sh
#
# Requirements:
#   - sops (https://github.com/mozilla/sops)
#   - age (https://github.com/FiloSottile/age)
#   - The age private key should be available locally and referenced via
#     SOPS_AGE_KEY_FILE (default: $HOME/.config/sops/age/age_key.txt)
#
set -euo pipefail

REPO_ROOT="/home/scon/config-repo"
TARGET_DIR="/run/config-repo-secrets"
SOPS_AGE_KEY_DEFAULT="${HOME}/.config/sops/age/age_key.txt"

# Allow override via env var
: "${SOPS_AGE_KEY_FILE:=$SOPS_AGE_KEY_DEFAULT}"

# If running as root via sudo and no SOPS_AGE_KEY_FILE is set, prefer the user's key if present
if [ -z "${SOPS_AGE_KEY_FILE:-}" ] && [ -f "/home/scon/.config/sops/age/age_key.txt" ]; then
  SOPS_AGE_KEY_FILE="/home/scon/.config/sops/age/age_key.txt"
fi
export SOPS_AGE_KEY_FILE

# Ensure sops is present
if ! command -v sops >/dev/null 2>&1; then
  echo "ERROR: sops is not installed or not in PATH" >&2
  exit 2
fi

# Ensure target tmpfs exists (create dir, systemd should mount, but create just in case)
if ! mountpoint -q "$TARGET_DIR"; then
  # create but do not mount; systemd tmp.mount is preferred
  mkdir -p "$TARGET_DIR"
  chmod 700 "$TARGET_DIR"
fi

# Ensure private key file exists and is protected
if [ ! -f "$SOPS_AGE_KEY_FILE" ]; then
  echo "WARNING: SOPS age key file not found at $SOPS_AGE_KEY_FILE" >&2
  echo "If you expect sops to use ssh-agent or another key mechanism, unset SOPS_AGE_KEY_FILE and ensure sops can access keys." >&2
else
  chmod 600 "$SOPS_AGE_KEY_FILE" || true
  export SOPS_AGE_KEY_FILE
fi

# Clean up stale decrypted files (remove everything under TARGET_DIR)
# Do NOT remove the TARGET_DIR itself to preserve mountpoint semantics
if [ -d "$TARGET_DIR" ]; then
  find "$TARGET_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} \;
fi

# Helper to compute destination filename
decrypt_file() {
  local src="$1"
  local rel="${src#$REPO_ROOT/}"     # relative to repo root
  local dest="$TARGET_DIR/${rel}"

  # Replace .enc.yaml/.enc.yml/.enc.json/.enc.env -> .yaml/.yml/.json/.env
  if [[ "$dest" =~ \.enc\.yaml$ ]]; then
    dest="${dest%.enc.yaml}.yaml"
  elif [[ "$dest" =~ \.enc\.yml$ ]]; then
    dest="${dest%.enc.yml}.yml"
  elif [[ "$dest" =~ \.enc\.json$ ]]; then
    dest="${dest%.enc.json}.json"
  elif [[ "$dest" =~ \.enc\.env$ ]]; then
    # Write dotenv-style secrets with a .env.dec suffix to avoid sops validating dotenv format.
    dest="${dest%.enc.env}.env.dec"
  else
    # Generic: remove first occurrence of ".enc"
    dest="${dest/.enc/}"
  fi

  local destdir
  destdir="$(dirname "$dest")"
  mkdir -p "$destdir"
  chmod 700 "$destdir"

  # Decrypt with sops to dest
  # sops will use SOPS_AGE_KEY_FILE if set, or other key helpers if available
  sops -d --output "$dest" "$src"
  chmod 600 "$dest"
}

export -f decrypt_file

# Find and decrypt files (only exact .enc.[yaml|yml|json] names to avoid backups matching)
find "$REPO_ROOT/docs/secrets" -type f \( -name '*.enc.yaml' -o -name '*.enc.yml' -o -name '*.enc.json' -o -name '*.enc.env' \) -print0 \
  | while IFS= read -r -d '' file; do
    echo "Decrypting: $file"
    decrypt_file "$file"
  done

# Optional: generate env files for specific services.
# Example (commented): convert a YAML secret file into a flat env file for docker-compose
# parse_yaml_to_env() { ... } # implement per-service if needed

echo "All secrets decrypted to $TARGET_DIR (permissions: dirs=700 files=600)."

# Post-process common secret files and produce small runtime files collect.sh expects
# This supports YAML/JSON/dotenv inputs and will write:
#   /run/config-repo-secrets/git_username
#   /run/config-repo-secrets/git_token
#   /run/config-repo-secrets/spotify_client_id
#   /run/config-repo-secrets/spotify_client_secret
python3 - <<'PY'
import os,sys
try:
    import yaml, json
except Exception:
    yaml = None
    json = None

T = os.environ.get('TARGET_DIR', '/run/config-repo-secrets')

def load_generic(path):
    text = ''
    try:
        with open(path, 'r', encoding='utf-8') as f:
            text = f.read()
    except Exception:
        return {}
    # Some sops outputs for .enc.env/.enc.json produce a JSON wrapper like:
    # { "data": "<raw file contents as a string>" }
    # If so, extract the inner 'data' string and parse that.
    if json:
        try:
            parsed = json.loads(text)
            if isinstance(parsed, dict) and 'data' in parsed and isinstance(parsed['data'], str):
                text = parsed['data']
        except Exception:
            # not JSON-wrapper; continue with original text
            pass
    # Try dotenv first (KEY=VAL)
    data = {}
    for line in text.splitlines():
        line=line.strip()
        if not line or line.startswith('#') or '=' not in line:
            continue
        k,v = line.split('=',1)
        data[k.strip()] = v.strip().strip('"').strip("'")
    if data:
        return data
    # Try YAML
    if yaml:
        try:
            parsed = yaml.safe_load(text)
            if isinstance(parsed, dict):
                return parsed
        except Exception:
            pass
    # Try JSON (fallback)
    if json:
        try:
            parsed = json.loads(text)
            if isinstance(parsed, dict):
                return parsed
        except Exception:
            pass
    return {}

def write_if_found(d, keys, outname):
    for k in keys:
        if k in d and d[k] is not None:
            path = os.path.join(T, outname)
            try:
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(str(d[k]) + "\n")
                os.chmod(path, 0o600)
            except Exception as e:
                print("Failed to write", path, ":", e)

# Candidate locations (where decrypt placed files)
git_candidates = [
    os.path.join(T, 'docs', 'secrets', 'git.env'),
    os.path.join(T, 'docs', 'secrets', 'git.enc.env'),
    os.path.join(T, 'docs', 'secrets', 'git.env.template'),
    os.path.join(T, 'docs', 'secrets', 'git.env.dec'),
    os.path.join(T, 'docs', 'secrets', 'git.env.dec'),
    os.path.join(T, 'docs', 'secrets', 'git.env.dec'),
    os.path.join(T, 'docs', 'secrets', 'git.yaml'),
    os.path.join(T, 'docs', 'secrets', 'git.yml'),
    os.path.join(T, 'docs', 'secrets', 'git.json'),
    os.path.join(T, 'git.env'),
    os.path.join(T, 'git.env.dec'),
    os.path.join(T, 'git.yaml'),
    os.path.join(T, 'git.yml'),
    os.path.join(T, 'git.json'),
]
spotify_candidates = [
    os.path.join(T, 'docs', 'secrets', 'spotify.env'),
    os.path.join(T, 'docs', 'secrets', 'spotify.enc.env'),
    os.path.join(T, 'docs', 'secrets', 'spotify.env.template'),
    os.path.join(T, 'docs', 'secrets', 'spotify.env.dec'),
    os.path.join(T, 'docs', 'secrets', 'spotify.yaml'),
    os.path.join(T, 'docs', 'secrets', 'spotify.yml'),
    os.path.join(T, 'docs', 'secrets', 'spotify.json'),
    os.path.join(T, 'spotify.env'),
    os.path.join(T, 'spotify.env.dec'),
    os.path.join(T, 'spotify.yaml'),
    os.path.join(T, 'spotify.yml'),
    os.path.join(T, 'spotify.json'),
]

# Process git
for p in git_candidates:
    if os.path.exists(p):
        data = load_generic(p)
        if data:
            write_if_found(data, ['GIT_USERNAME', 'git_username', 'username', 'user'], 'git_username')
            write_if_found(data, ['GIT_TOKEN', 'git_token', 'token', 'password'], 'git_token')
            print("Processed git secrets from", p)
            break

# Process spotify
for p in spotify_candidates:
    if os.path.exists(p):
        data = load_generic(p)
        if data:
            write_if_found(data, ['SPOTIFY_CLIENT_ID', 'spotify_client_id', 'client_id'], 'spotify_client_id')
            write_if_found(data, ['SPOTIFY_CLIENT_SECRET', 'spotify_client_secret', 'client_secret'], 'spotify_client_secret')
            print("Processed spotify secrets from", p)
            break

print("Post-processing complete. Runtime secret files (if any) are in", T)
PY

exit 0
