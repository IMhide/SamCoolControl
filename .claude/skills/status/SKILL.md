---
name: status
description: Display a full status dashboard of the Coolify server. Use when the user asks for an overview, "status", or the state of servers/apps/databases/services/deployments.
---

# /status

Display a full status dashboard of the active Coolify infra.

1. Resolve the active infra first: `./scripts/infra current` (mention which infra you're querying).
   To target another, use `./scripts/coolify --infra <name> status`.
2. Run `./scripts/coolify status` and present the results clearly.
3. Highlight any issues: unreachable servers, failed deployments, stopped/degraded services.

The dashboard already prints the active infra + base_url on its first line.

> Tip: if a service shows `degraded`/`unhealthy`, check the infra's `incidents/INDEX.md`
> (`./scripts/memory search <service>`) — there may be a known fix.
