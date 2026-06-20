---
name: manage
description: Perform a lifecycle action (start/stop/restart) on a Coolify resource (app, database, service). Use when the user wants to start, stop, or restart something.
---

# /manage

Perform a lifecycle action on a Coolify resource.

Usage: `/manage <action> <resource-type> <uuid>` (optionally `--infra <name>`).

Actions: `start`, `stop`, `restart`. Resource types: `app`, `database`/`db`, `service`.

Steps:
1. **Confirm the target infra** (name + base_url) — these are write operations. `stop` especially
   takes a resource offline; double-check the UUID against `infras/<infra>/registry.md`.
2. Validate the action and resource type.
3. Run the command, e.g. `./scripts/coolify app:restart <uuid>`, `./scripts/coolify service:stop <uuid>`.
4. Report the result and offer to check status afterwards.

If arguments are missing, ask interactively. For a service stuck after restart, see
`decisions/global/0003` (DELETE+recreate) and `cookbook/global/0003`.
