---
name: servers
description: List all Coolify servers and their status. Use when the user wants to see servers, their UUIDs, IPs, or reachability.
---

# /servers

List all servers of the active Coolify infra.

1. Resolve/confirm the active infra (`./scripts/infra current`). To target another:
   `./scripts/coolify --infra <name> servers`.
2. Run `./scripts/coolify servers`.
3. For each server, show: UUID, name, IP, reachability status.

> The active infra's primary `server_uuid` is recorded in `infras/<infra>/infra.yaml` and `facts.md`.
