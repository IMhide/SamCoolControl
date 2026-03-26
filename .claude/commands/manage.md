Perform a lifecycle action (start/stop/restart) on a Coolify resource.

Usage: /manage <action> <resource-type> <uuid>

Actions: start, stop, restart
Resource types: app, database, db, service

Steps:
1. Validate the action and resource type
2. Run the appropriate command, e.g., `./scripts/coolify app:restart <uuid>`
3. Report the result
4. Offer to check the status afterwards

If arguments are missing, interactively ask the user what they want to do.
