#!/usr/bin/env python3
import os
import sys
import subprocess
from datetime import datetime
from pathlib import Path

# Configuration
IGNORE = {
    '.git', 'system_snapshot', '__pycache__', 'node_modules', '.venv',
    'containers/docker/runtime-snapshots', '.DS_Store'
}
REPO_ROOT = Path(__file__).resolve().parent.parent
README = REPO_ROOT / "README.md"

def build_tree(dir_path: Path, prefix: str = ""):
    entries = sorted([
        p for p in dir_path.iterdir()
        if p.name not in IGNORE
    ], key=lambda p: (not p.is_dir(), p.name.lower()))
    lines = []
    for idx, p in enumerate(entries):
        connector = "├── " if idx < len(entries) - 1 else "└── "
        lines.append(f"{prefix}{connector}{p.name}")
        if p.is_dir():
            extension = "│   " if idx < len(entries) - 1 else "    "
            lines.extend(build_tree(p, prefix + extension))
    return lines

def generate_block():
    lines = ["```text"]
    lines.extend(build_tree(REPO_ROOT))
    lines.append("```")
    return "\n".join(lines)

def refresh_readme():
    block = generate_block()
    text = README.read_text().splitlines()
    out = []
    in_block = False
    markers_present = False

    for line in text:
        if line.strip() == "<!-- BEGIN:STRUCTURE -->":
            out.append(line)
            out.append(block)
            in_block = True
            markers_present = True
        elif in_block and line.strip() == "<!-- END:STRUCTURE -->":
            out.append(line)
            in_block = False
        elif in_block:
            continue
        else:
            out.append(line)

    if not markers_present:
        # Insert after the "## Structure" header
        new_out = []
        inserted = False
        for line in out:
            new_out.append(line)
            if not inserted and line.strip() == "## Structure":
                new_out.append("<!-- BEGIN:STRUCTURE -->")
                new_out.append(block)
                new_out.append("<!-- END:STRUCTURE -->")
                inserted = True
        out = new_out

    README.write_text("\n".join(out) + "\n")

def commit_and_push():
    # Check for changes
    diff = subprocess.run(
        ["git", "diff", "--name-only"], cwd=str(REPO_ROOT),
        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True
    )
    if not diff.stdout.strip():
        return
    subprocess.run(["git", "add", "README.md"], cwd=str(REPO_ROOT), check=True)
    msg = f"[auto] docs: refresh README structure ({datetime.now().isoformat()})"
    subprocess.run(["git", "commit", "-m", msg], cwd=str(REPO_ROOT), check=True)
    subprocess.run(["git", "push"], cwd=str(REPO_ROOT), check=True)

def main():
    refresh_readme()
    commit_and_push()

if __name__ == "__main__":
    main()
