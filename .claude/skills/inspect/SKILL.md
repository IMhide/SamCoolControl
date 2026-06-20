---
name: inspect
description: Inspect a Coolify resource in detail (server, app, database, service, project, deployment). Use when the user wants full details/config of one resource.
---

# /inspect

Inspect a Coolify resource in detail.

Usage: `/inspect <resource-type> <uuid>` (optionally `--infra <name>`).

Resource types: `server`, `app`, `database`/`db`, `service`, `project`, `deployment`.

Steps:
1. Resolve/confirm the active infra (`./scripts/infra current`).
2. Map the type to the CLI command (e.g. `app` → `./scripts/coolify app <uuid>`,
   `service` → `./scripts/coolify service <uuid>`).
3. Run it and present the JSON readably. Highlight: name, status, URLs/FQDN, key config.
4. If the resource has sub-resources (envs, domains, resources), offer to show them
   (`app:envs`, `service:envs`, `server:domains`, `server:resources`).

If no arguments are provided, ask what to inspect. Consult `infras/<infra>/registry.md` to resolve
names ↔ UUIDs.
