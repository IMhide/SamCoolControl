Deploy an application on Coolify.

Usage: /deploy <app-name-or-uuid>

Steps:
1. If the argument looks like a UUID, deploy directly with `./scripts/coolify deploy <uuid>`
2. If it's a name, first run `./scripts/coolify apps` to find the matching UUID, then deploy
3. Show the deployment status after triggering
4. If `--force` is appended, pass the force flag

If no argument is provided, list all applications and ask the user which one to deploy.
