# Coolify Control - Claude Code Guide

## Project Overview

This project provides CLI tools and Claude Code prompts to manage a **Coolify** server instance via its REST API. Coolify is a self-hosted PaaS (like Heroku/Vercel).

## IMPORTANT: Read API_REFERENCE.md

**Before any Coolify operation, you MUST read `API_REFERENCE.md` at the project root.** It contains the exhaustive API documentation: every endpoint, every parameter (name, type, required/optional, defaults), request/response schemas, and multi-step workflow recipes. This is your source of truth for building API calls.

Always `Read API_REFERENCE.md` at the start of a conversation that involves Coolify operations.

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

When the user asks to interact with their Coolify server:

1. **Read `API_REFERENCE.md`** to know the exact endpoint, parameters, and workflow
2. Use `./scripts/coolify` CLI commands for simple operations
3. Use `./scripts/coolify raw <METHOD> <PATH> '<JSON>'` for create/update/delete or any advanced operation
4. Chain multiple API calls for complex workflows (see "Common Multi-Step Workflows" in API_REFERENCE.md)

### Simple operations (use CLI)

| Task | Command |
|------|---------|
| Overview | `./scripts/coolify status` |
| List resources | `./scripts/coolify servers`, `apps`, `databases`, `services` |
| Inspect | `./scripts/coolify app <uuid>`, `server <uuid>`, etc. |
| Lifecycle | `./scripts/coolify app:start <uuid>`, `app:stop`, `app:restart` |
| Deploy | `./scripts/coolify deploy <uuid>` or `deploy:tag <tag>` |
| Env vars | `./scripts/coolify app:envs <uuid>`, `app:env:set <uuid> KEY VALUE` |

### Complex operations (use raw API)

Use `./scripts/coolify raw` for anything not covered by the CLI. Always refer to `API_REFERENCE.md` for the exact parameters.

```bash
# Create a PostgreSQL database
./scripts/coolify raw POST /databases/postgresql '{"server_uuid":"...","project_uuid":"...","environment_name":"production","name":"my-db","instant_deploy":true}'

# Create an app from Docker image
./scripts/coolify raw POST /applications/dockerimage '{"server_uuid":"...","project_uuid":"...","environment_name":"production","name":"my-app","docker_registry_image_name":"nginx","ports_exposes":"80","instant_deploy":true}'

# Bulk set env vars
./scripts/coolify raw PATCH /applications/{uuid}/envs/bulk '[{"key":"K1","value":"V1"},{"key":"K2","value":"V2"}]'

# Update application config
./scripts/coolify raw PATCH /applications/{uuid} '{"fqdn":"https://new.example.com"}'
```

### Key patterns

- All bodies are JSON with `Content-Type: application/json`
- Most creation endpoints accept `instant_deploy: true`
- UUIDs are returned in creation responses
- Use `force_domain_override: true` to bypass domain conflict 409 errors
- For multi-step workflows, read the "Common Multi-Step Workflows" section in API_REFERENCE.md

## Slash commands

Custom prompts are available in `.claude/commands/` for common Coolify operations:

| Command | Description |
|---------|-------------|
| `/status` | Full dashboard overview |
| `/servers` | List all servers |
| `/apps` | List all applications |
| `/deploy` | Deploy an application |
| `/inspect` | Inspect a resource in detail |
| `/manage` | Start/stop/restart a resource |
| `/envs` | Manage environment variables |
| `/create-app` | Interactive app creation wizard |
| `/create-db` | Interactive database creation wizard |
| `/api` | Raw API call |
