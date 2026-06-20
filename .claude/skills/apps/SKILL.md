---
name: apps
description: List all applications deployed on Coolify. Use when the user wants to see apps, their UUIDs, status, or FQDNs.
---

# /apps

List all applications of the active Coolify infra.

1. Resolve/confirm the active infra (`./scripts/infra current`). To target another:
   `./scripts/coolify --infra <name> apps`.
2. Run `./scripts/coolify apps`.
3. For each app show: UUID, name, status, FQDN.

> Known apps for the active infra are also catalogued in `infras/<infra>/registry.md`.
