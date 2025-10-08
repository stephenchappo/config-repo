Configuration Documentation Policy (Canonical location: ~/config-repo)
--------------------------------------------------------------------

Canonical path
- All troubleshooting and operational documentation MUST be saved under:
  ~/config-repo/
- Recommended subdirectory for issue docs:
  ~/config-repo/troubleshooting/

Assistant behavior (persisted policy)
- When asked to create or update troubleshooting/config documentation, the assistant will:
  1. Create directories under ~/config-repo/ as needed.
  2. Write new files to the appropriate subdirectory under ~/config-repo/ (e.g., ~/config-repo/troubleshooting/).
  3. If a file with the same path already exists, create a backup before overwriting:
     cp /home/scon/config-repo/path/to/file /home/scon/config-repo/path/to/file.bak.$(date +%s)
  4. Set file permissions to 0644 and set ownership to the invoking user.
  5. Notify the user of the file path after writing.

Backups and safety
- The assistant will make a timestamped backup if asked or when overwriting an existing file.
- The assistant will not change files outside the canonical directory unless explicitly instructed.

To revert or move files manually:
- mv /home/scon/config-repo/troubleshooting/qbittorrent-radarr-proxy.md docs/troubleshooting/

