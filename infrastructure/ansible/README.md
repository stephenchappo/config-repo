# Ansible Playbooks

This directory contains Ansible playbooks and roles for provisioning infrastructure.

Structure:
- inventories/        ← host inventory files (e.g., production, staging)
- playbooks/          ← main playbooks (e.g., site.yml)
- roles/              ← reusable roles

Usage:
```bash
ansible-playbook -i inventories/production site.yml
