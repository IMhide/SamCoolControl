# Coolify Control - Claude Code Guide

## Project Overview

This project provides CLI tools and Claude Code prompts to manage a **Coolify** server instance via its REST API. Coolify is a self-hosted PaaS (like Heroku/Vercel).

## Configuration

- Copy `.env.example` to `.env` and set `COOLIFY_BASE_URL` and `COOLIFY_API_TOKEN`
- API tokens are generated from the Coolify UI: **Keys & Tokens > API tokens**
- Token scopes: `read`, `write`, `deploy`

## Scripts

- `scripts/coolify` - High-level CLI with human-friendly commands
- `scripts/coolify-api.sh` - Low-level API wrapper (can be sourced in bash or called directly)

### CLI usage

```bash
./scripts/coolify status          # Dashboard overview
./scripts/coolify servers         # List servers
./scripts/coolify apps            # List applications
./scripts/coolify deploy <uuid>   # Trigger deployment
./scripts/coolify raw GET /path   # Raw API call
```

### Using the API wrapper in scripts

```bash
source scripts/coolify-api.sh
coolify_api GET /servers
coolify_api POST /applications '{"name":"my-app"}'
```

## How to assist the user with Coolify operations

When the user asks to interact with their Coolify server, use the bash tool to run `scripts/coolify` commands or call `scripts/coolify-api.sh` directly. Always prefer the high-level CLI first.

### Common workflows

1. **Get an overview**: `./scripts/coolify status`
2. **List resources**: `./scripts/coolify servers`, `apps`, `databases`, `services`
3. **Inspect a resource**: `./scripts/coolify app <uuid>`, `server <uuid>`, etc.
4. **Lifecycle actions**: `./scripts/coolify app:start <uuid>`, `app:stop`, `app:restart`
5. **Deploy**: `./scripts/coolify deploy <uuid>` or `deploy:tag <tag>`
6. **Env vars**: `./scripts/coolify app:envs <uuid>`, `app:env:set <uuid> KEY VALUE`
7. **Raw API for advanced cases**: `./scripts/coolify raw POST /databases/postgresql '{"server_uuid":"...","project_uuid":"...","environment_name":"production"}'`

### When creating resources via API

Use `./scripts/coolify raw` for create/update operations. Key patterns:
- All bodies are JSON with `Content-Type: application/json`
- Most creation endpoints accept `instant_deploy: true` for immediate deployment
- UUIDs are returned in creation responses

## Coolify API Reference (v1)

Base: `{COOLIFY_BASE_URL}/api/v1`

### Authentication
All requests require: `Authorization: Bearer <token>`

### Endpoints

| Resource | List | Get | Create | Update | Delete | Actions |
|----------|------|-----|--------|--------|--------|---------|
| Servers | `GET /servers` | `GET /servers/{uuid}` | `POST /servers` | `PATCH /servers/{uuid}` | `DELETE /servers/{uuid}` | `/validate`, `/resources`, `/domains` |
| Applications | `GET /applications` | `GET /applications/{uuid}` | `POST /applications/public`, `/private-github-app`, `/private-deploy-key`, `/dockerfile`, `/dockerimage` | `PATCH /applications/{uuid}` | `DELETE /applications/{uuid}` | `/start`, `/stop`, `/restart`, `/logs`, `/envs` |
| Databases | `GET /databases` | `GET /databases/{uuid}` | `POST /databases/{type}` (postgresql, mysql, mariadb, mongodb, redis, clickhouse, dragonfly, keydb) | `PATCH /databases/{uuid}` | `DELETE /databases/{uuid}` | `/start`, `/stop`, `/restart`, `/backups` |
| Services | `GET /services` | `GET /services/{uuid}` | `POST /services` | `PATCH /services/{uuid}` | `DELETE /services/{uuid}` | `/start`, `/stop`, `/restart`, `/envs` |
| Projects | `GET /projects` | `GET /projects/{uuid}` | `POST /projects` | `PATCH /projects/{uuid}` | `DELETE /projects/{uuid}` | `/environments` |
| Deployments | `GET /deployments` | `GET /deployments/{uuid}` | `GET /deploy?uuid=X` | - | - | `/cancel` |
| Teams | `GET /teams` | `GET /teams/{id}` | - | - | - | `/members`, `/current` |
| Private Keys | `GET /private-keys` | `GET /private-keys/{uuid}` | `POST /private-keys` | `PATCH /private-keys/{uuid}` | `DELETE /private-keys/{uuid}` | - |
| Resources | `GET /resources` | - | - | - | - | - |
| System | `GET /version`, `GET /healthcheck` | - | - | - | - | - |

### HTTP Status Codes
- **200**: Success
- **400**: Invalid token
- **401**: Unauthenticated
- **404**: Resource not found
- **409**: Domain conflict (use `force_domain_override: true` to bypass)
- **422**: Validation error (check `errors` field)
- **429**: Rate limited (check `Retry-After` header)

## Slash commands

Custom prompts are available in `.claude/commands/` for common Coolify operations.
