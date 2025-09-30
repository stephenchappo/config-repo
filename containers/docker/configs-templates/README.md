# Service Configuration Templates

This directory contains sanitized configuration templates for each service.

Conventions:
- Place sanitized templates under `configs-templates/<service>/`.
- Template files must have a `.template` suffix.
- All secrets and sensitive values (API keys, tokens, passwords, private keys) should be replaced with:
  - `${REDACTED}` (plaintext values)
  - `<REDACTED>` (XML/HTML content)
  - `${ENV_VAR}` (if value should be provided via environment variable)
- Templates should preserve the original structure, comments, and placeholders.
- Do not include any real secrets in this repository. Use `sanitize-configs.sh` to generate templates.

Usage:
```bash
containers/docker/scripts/sanitize-configs.sh \
  --service <service> \
  --src /srv/docker/<service>/config \
  --out containers/docker/configs-templates/<service>
