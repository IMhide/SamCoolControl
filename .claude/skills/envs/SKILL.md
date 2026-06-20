---
name: envs
description: Manage environment variables for a Coolify application or service (list/set). Use when the user wants to view or change env vars.
---

# /envs

Manage environment variables for an application or service.

Usage: `/envs <resource-type> <uuid> [action] [key] [value]` (optionally `--infra <name>`).

Actions:
- `list` (default): show all env vars.
- `set`: set an env var (requires key and value).

Steps:
1. Resolve/confirm the active infra. For `set`, **confirm the target infra** first (write op).
2. List: `./scripts/coolify app:envs <uuid>` or `./scripts/coolify service:envs <uuid>`.
3. Set (app): `./scripts/coolify app:env:set <uuid> <key> <value>`.
   Set (service/bulk/build-time): use `raw` — e.g.
   `./scripts/coolify raw PATCH /services/<uuid>/envs '{"key":"K","value":"V"}'`, or
   `PATCH /applications/<uuid>/envs/bulk` with `{data:[…]}` (build args via `is_build_time`/`is_runtime`).
   Build JSON with `jq` (`habits/global/0001`).
4. **Mask sensitive values** (passwords, tokens, secrets) in your output.

> ⚠️ Never expose a SERVICE_ROLE / admin key in a frontend. See `infras/<infra>/registry.md` and the
> security rules. Secrets stay local. If arguments are missing, ask what's needed.
