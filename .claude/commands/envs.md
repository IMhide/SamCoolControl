Manage environment variables for a Coolify application or service.

Usage: /envs <resource-type> <uuid> [action] [key] [value]

Actions:
- list (default): Show all env vars
- set: Set an env var (requires key and value)

Steps:
1. If action is "list" or omitted: run `./scripts/coolify app:envs <uuid>` or `service:envs <uuid>`
2. If action is "set": run `./scripts/coolify app:env:set <uuid> <key> <value>`
3. Display results clearly, masking sensitive values (passwords, tokens, secrets)

If arguments are missing, ask the user what they need.
