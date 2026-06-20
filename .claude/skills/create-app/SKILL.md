---
name: create-app
description: Create a new application on Coolify (interactive wizard). Use when the user wants to create/add an app from a git repo, Dockerfile, or Docker image.
---

# /create-app

Create a new application on Coolify (interactive).

**Before building any call: `Read API_REFERENCE.md`** for the exact endpoint + params, and run the
RAG protocol (`./scripts/memory search …`) — there are battle-tested recipes (e.g. Docker image
HTTPS via Traefik in `cookbook/global/0001`; Lovable SSR apps in `cookbook/global/0005`).

1. **Confirm the target infra** (name + base_url) — creation is a write op.
2. Ask for the application type → endpoint:
   - Public Git repo → `/applications/public`
   - Private GitHub App → `/applications/private-github-app`
   - Private Deploy Key → `/applications/private-deploy-key`
   - Dockerfile → `/applications/dockerfile`
   - Docker Image → `/applications/dockerimage`
3. Gather required params (server_uuid, project_uuid, environment_name; + type-specific). Help find
   UUIDs via `./scripts/coolify servers` / `projects` and `infras/<infra>/facts.md`.
4. Apply the house habits: prefer `instant_deploy:false` then configure domain/volumes/envs then
   start (`habits/global/0002`); set the domain via PATCH `domains` not `fqdn` (`decisions/global/0002`);
   for a single HTTPS container prefer an Application over a Service (`decisions/global/0001`).
5. Build the JSON body with `jq` and run:
   `./scripts/coolify raw POST /applications/<type> '<json>'`.
6. Show the result + the new UUID.
7. **Record the new app** in `infras/<infra>/registry.md`, and trigger `/learn` if a decision or
   pitfall emerged (Option B).
