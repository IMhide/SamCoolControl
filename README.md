# Coolify Control

CLI tools and Claude Code integration to manage a Coolify server from the terminal.

## Setup

```bash
# 1. Configure your Coolify credentials
cp .env.example .env
# Edit .env with your COOLIFY_BASE_URL and COOLIFY_API_TOKEN

# 2. Verify connectivity
./scripts/coolify health
./scripts/coolify version
```

## CLI Usage

```bash
# Overview dashboard
./scripts/coolify status

# Servers
./scripts/coolify servers
./scripts/coolify server <uuid>
./scripts/coolify server:validate <uuid>

# Applications
./scripts/coolify apps
./scripts/coolify app <uuid>
./scripts/coolify app:start <uuid>
./scripts/coolify app:stop <uuid>
./scripts/coolify app:restart <uuid>
./scripts/coolify deploy <uuid>

# Databases
./scripts/coolify databases
./scripts/coolify db:start <uuid>
./scripts/coolify db:stop <uuid>

# Services
./scripts/coolify services
./scripts/coolify service:start <uuid>

# Environment variables
./scripts/coolify app:envs <uuid>
./scripts/coolify app:env:set <uuid> KEY VALUE

# Raw API
./scripts/coolify raw GET /servers
./scripts/coolify raw POST /projects '{"name":"new-project"}'
```

Run `./scripts/coolify help` for the full command list.

## Claude Code Slash Commands

When using this project with Claude Code, the following slash commands are available:

| Command | Description |
|---------|-------------|
| `/status` | Full dashboard overview |
| `/servers` | List all servers |
| `/apps` | List all applications |
| `/deploy <uuid>` | Deploy an application |
| `/inspect <type> <uuid>` | Inspect a resource in detail |
| `/manage <action> <type> <uuid>` | Start/stop/restart a resource |
| `/envs <type> <uuid>` | Manage environment variables |
| `/create-app` | Interactive app creation |
| `/create-db` | Interactive database creation |
| `/api <METHOD> <PATH>` | Raw API call |

## API Token

Generate an API token from your Coolify dashboard:
1. Go to **Keys & Tokens** > **API tokens**
2. Create a token with the scopes you need: `read`, `write`, `deploy`
3. Copy the token to your `.env` file

## Requirements

- `curl`
- `jq`
- Bash 4+
