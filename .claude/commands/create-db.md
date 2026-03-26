Create a new database on Coolify.

Usage: /create-db

This is an interactive command. Walk the user through creating a database:

1. Ask for the database type:
   - PostgreSQL, MySQL, MariaDB, MongoDB, Redis, ClickHouse, Dragonfly, KeyDB

2. Gather required parameters:
   - server_uuid (help find with `./scripts/coolify servers`)
   - project_uuid (help find with `./scripts/coolify projects`)
   - environment_name (default: "production")

3. Ask about optional settings:
   - name, description
   - instant_deploy (default: true)
   - is_public, public_port
   - Resource limits (limits_memory, limits_cpus)
   - Database-specific: root password, default database name, etc.

4. Build the JSON body and run: `./scripts/coolify raw POST /databases/<type> '<json>'`

5. Show the result and the new database UUID
