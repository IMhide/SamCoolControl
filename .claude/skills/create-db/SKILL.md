---
name: create-db
description: Create a new database on Coolify (interactive wizard). Use when the user wants to add a PostgreSQL/MySQL/MariaDB/MongoDB/Redis/etc. database.
---

# /create-db

Create a new database on Coolify (interactive).

**Before building any call: `Read API_REFERENCE.md`** for the exact endpoint + params, and run the
RAG protocol (`./scripts/memory search database`).

1. **Confirm the target infra** (name + base_url) — creation is a write op.
2. Ask for the database type: PostgreSQL, MySQL, MariaDB, MongoDB, Redis, ClickHouse, Dragonfly,
   KeyDB → endpoint `/databases/<type>`.
3. Gather required params: server_uuid (`./scripts/coolify servers`), project_uuid
   (`./scripts/coolify projects`), environment_name (default `production`).
4. Optional settings: name, description, `instant_deploy`, `is_public`/`public_port`, resource
   limits (`limits_memory`, `limits_cpus`), and DB-specific (root password, default db name…).
5. Build the JSON body with `jq` and run:
   `./scripts/coolify raw POST /databases/<type> '<json>'`.
6. Show the result + the new UUID.
7. **Record the new database** in `infras/<infra>/registry.md`; store any credential there (local
   only), never in versioned memory.
