Inspect a Coolify resource in detail.

Usage: /inspect <resource-type> <uuid>

Resource types: server, app, database, db, service, project, deployment

Steps:
1. Map the resource type to the correct CLI command (e.g., "app" -> `./scripts/coolify app <uuid>`)
2. Run the command and display the full JSON output in a readable format
3. Highlight key information: name, status, URLs, configuration
4. If the resource has sub-resources (envs, domains, resources), offer to show them

If no arguments are provided, ask the user what they want to inspect.
