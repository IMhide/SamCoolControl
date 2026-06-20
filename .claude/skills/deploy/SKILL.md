---
name: deploy
description: Deploy an application on Coolify. Use when the user wants to deploy, redeploy, or trigger a build of an app (by name or UUID).
---

# /deploy

Deploy an application on Coolify.

Usage: `/deploy <app-name-or-uuid> [--force]` (optionally `--infra <name>`).

Steps:
1. **Confirm the target infra** (name + base_url from `infra.yaml`) before triggering — deploy is a
   write operation. `./scripts/infra current` / target with `./scripts/coolify --infra <name> …`.
2. If the argument looks like a UUID → `./scripts/coolify deploy <uuid>`.
3. If it's a name → run `./scripts/coolify apps` to find the matching UUID, then deploy. Cross-check
   with `infras/<infra>/registry.md`.
4. If `--force` is appended, pass the force flag.
5. Show the deployment status after triggering. For a broken build, see `cookbook/global/0003`
   (`./scripts/memory search broken deploy`).

If no argument is provided, list applications and ask which one to deploy.

> If this app was set up with a special pattern (e.g. Lovable SSR), check
> `./scripts/memory search <app>` and `architecture/INDEX.md` before assuming a plain redeploy.
