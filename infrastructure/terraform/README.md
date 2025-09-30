# Terraform Configurations

This directory contains Terraform modules and configurations for provisioning cloud resources.

Structure:
- modules/          ← reusable Terraform modules
- envs/             ← environment-specific root configurations (e.g., prod, staging)
- backend.tf        ← remote state backend configuration
- variables.tf      ← shared variables definitions
- outputs.tf        ← shared outputs definitions

Usage:
```bash
cd infrastructure/terraform/envs/prod
terraform init
terraform apply
