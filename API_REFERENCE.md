# Coolify API v1 - Complete Reference

> This file is loaded into Claude Code's context via CLAUDE.md.
> It contains every endpoint, parameter, and pattern needed to orchestrate complex multi-step operations.

## Authentication

```
Authorization: Bearer <token>
Content-Type: application/json
Accept: application/json
```

**Token scopes:** `read`, `write`, `deploy`
Tokens are team-scoped. All resources are filtered by the token's team.

## Base URL

`{COOLIFY_BASE_URL}/api/v1`

---

## Quick Cheat Sheet

| Action | Command |
|--------|---------|
| List servers | `GET /servers` |
| List apps | `GET /applications` |
| List databases | `GET /databases` |
| List services | `GET /services` |
| List projects | `GET /projects` |
| Deploy by UUID | `GET /deploy?uuid={uuid}&force=false` |
| Deploy by tag | `GET /deploy?tag={tag}&force=false` |
| API version | `GET /version` |

---

## 1. Servers

### GET /servers
List all servers for the team.
**Response:** `[{ uuid, name, ip, description, settings: { is_reachable, is_usable, ... }, ... }]`

### POST /servers
Create a new server.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | yes | Server identifier |
| `ip` | string | yes | IP address or hostname |
| `private_key_uuid` | string | yes | SSH key UUID |
| `description` | string | no | Description |
| `port` | integer | no | SSH port (default: 22) |
| `user` | string | no | SSH user (default: root) |
| `instant_validate` | boolean | no | Validate immediately after creation |

**Response:** `201 { uuid, message }`

### GET /servers/{uuid}
Full server details with settings.
**Response:** `{ uuid, name, ip, port, user, description, settings: { is_reachable, is_usable, is_swarm_manager, is_swarm_worker, sentinel_token, ... }, created_at, updated_at }`

### PATCH /servers/{uuid}
Update server. **Updatable:** `name`, `description`, `ip`, `port`, `user`, `private_key_uuid`

### DELETE /servers/{uuid}
Delete server and all associated resources.

### GET /servers/{uuid}/resources
All resources deployed on this server.
**Response:** `{ applications: [...], databases: [...], services: [...] }`

### GET /servers/{uuid}/domains
All domains across all resources on this server.
**Response:** `[{ ip, domains: [...] }]`

### GET /servers/{uuid}/validate
Triggers SSH + Docker + Sentinel validation. Updates `is_reachable` and `is_usable` flags.
**Response:** `{ message }`

---

## 2. Applications

### GET /applications
List all applications. Optional query: `?tag=my-tag`
**Response:** `[{ uuid, name, fqdn, status, git_repository, build_pack, ... }]`

### POST /applications/public
Create from public git repository.

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | string | yes | - | Application name |
| `git_repository` | string | yes | - | Full repo URL |
| `git_branch` | string | yes | - | Branch to deploy |
| `project_uuid` | string | yes | - | Parent project UUID |
| `environment_name` | string | yes | - | Environment name or UUID |
| `server_uuid` | string | yes | - | Destination server UUID |
| `description` | string | no | - | Description |
| `build_pack` | string | no | nixpacks | `nixpacks`, `dockerfile`, `dockerimage`, `dockercompose`, `static` |
| `ports_exposes` | string | no | - | Exposed ports (e.g. `"3000"`) |
| `instant_deploy` | boolean | no | false | Deploy immediately |
| `autogenerate_domain` | boolean | no | true | Auto-generate FQDN |
| `force_domain_override` | boolean | no | false | Bypass domain conflicts |
| `docker_compose_domains` | object | no | - | Map service names to URLs |

**Response:** `201 { uuid, ... }`

### POST /applications/private-github-app
Same as public + `github_app_uuid` (string, required).

### POST /applications/private-deploy-key
Same as public + `private_key_uuid` (string, required).

### POST /applications/dockerfile
Create from Dockerfile (without full git repo).

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | yes | Application name |
| `project_uuid` | string | yes | Parent project UUID |
| `environment_name` | string | yes | Environment name |
| `server_uuid` | string | yes | Server UUID |
| `dockerfile` | string | yes | Dockerfile content (raw) |
| `instant_deploy` | boolean | no | Deploy immediately |

### POST /applications/dockerimage
Create from Docker image (no git).

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | string | yes | - | Application name |
| `project_uuid` | string | yes | - | Parent project UUID |
| `environment_name` | string | yes | - | Environment name |
| `server_uuid` | string | yes | - | Server UUID |
| `docker_registry_image_name` | string | yes | - | Image name (e.g. `nginx`) |
| `docker_registry_image_tag` | string | no | latest | Image tag |
| `ports_exposes` | string | no | - | Exposed ports |
| `instant_deploy` | boolean | no | false | Deploy immediately |

### GET /applications/{uuid}
Full application details.

### PATCH /applications/{uuid}
Update application. **Updatable fields:**
`name`, `description`, `fqdn`, `git_repository`, `git_branch`, `git_commit_sha`,
`docker_registry_image_name`, `docker_registry_image_tag`,
`build_pack`, `ports_exposes`, `ports_mappings`,
`custom_labels`, `custom_docker_run_parameters`,
`custom_healthcheck_enabled`, `custom_healthcheck_curl`,
`limits_memory`, `limits_cpus`, `limits_swap`, `limits_cpuset`

### DELETE /applications/{uuid}
Delete application. Optional query params: `?delete_configurations=true&delete_volumes=true&docker_cleanup=true`

### Application Lifecycle

| Endpoint | Description |
|----------|-------------|
| `GET /applications/{uuid}/start` | Deploy/start the application |
| `GET /applications/{uuid}/stop` | Stop the application |
| `GET /applications/{uuid}/restart` | Restart the application |
| `GET /applications/{uuid}/logs` | Get container logs |

### Application Environment Variables

**GET /applications/{uuid}/envs**
→ `[{ uuid, key, value, is_build_time, is_preview, is_shown_once }]`

**POST /applications/{uuid}/envs**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `key` | string | yes | - | Variable name |
| `value` | string | yes | - | Variable value |
| `is_build_time` | boolean | no | false | Available at build time |
| `is_preview` | boolean | no | false | Available in preview deployments |
| `is_shown_once` | boolean | no | false | Show value only once |

**PATCH /applications/{uuid}/envs/bulk**
Body: `[{ "key": "K1", "value": "V1" }, ...]`

**PATCH /applications/{uuid}/envs**
Update a single env var: `{ "uuid": "<env-uuid>", "key": "K", "value": "V" }`

**DELETE /applications/{uuid}/envs/{env_uuid}**

---

## 3. Databases

### GET /databases
List all databases.
**Response:** `[{ uuid, name, type, status, ... }]`

### POST /databases/{type}

**Types:** `postgresql`, `mysql`, `mariadb`, `mongodb`, `redis`, `clickhouse`, `dragonfly`, `keydb`

#### Common parameters (all types)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | string | no | auto | Database name |
| `description` | string | no | - | Description |
| `project_uuid` | string | yes | - | Parent project UUID |
| `environment_name` | string | yes | - | Environment name |
| `server_uuid` | string | yes | - | Destination server UUID |
| `instant_deploy` | boolean | no | false | Deploy immediately |
| `is_public` | boolean | no | false | Expose publicly |
| `public_port` | integer | no | - | Public port (if is_public) |
| `limits_memory` | string | no | - | Memory limit (e.g. `"2g"`) |
| `limits_cpus` | string | no | - | CPU limit (e.g. `"2"`) |
| `image` | string | no | varies | Docker image override |

#### Type-specific parameters

**PostgreSQL:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `postgres_user` | string | auto | Root username |
| `postgres_password` | string | auto | Root password |
| `postgres_db` | string | auto | Default database name |

**MySQL:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `mysql_user` | string | auto | Username |
| `mysql_password` | string | auto | User password |
| `mysql_root_password` | string | auto | Root password |
| `mysql_database` | string | auto | Default database |

**MariaDB:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `mariadb_user` | string | auto | Username |
| `mariadb_password` | string | auto | User password |
| `mariadb_root_password` | string | auto | Root password |
| `mariadb_database` | string | auto | Default database |

**MongoDB:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `mongo_initdb_root_username` | string | auto | Root username |
| `mongo_initdb_root_password` | string | auto | Root password |

**Redis / Dragonfly / KeyDB:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `redis_password` | string | auto | Access password |
| `redis_conf` | string | - | Custom config |

**ClickHouse:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `clickhouse_admin_user` | string | auto | Admin username |
| `clickhouse_admin_password` | string | auto | Admin password |

**Response:** `201 { uuid, ... }`

### GET /databases/{uuid}
Full database details with connection info.

### PATCH /databases/{uuid}
Update database configuration. Same fields as creation (type-specific).

### DELETE /databases/{uuid}
Delete database. Optional: `?delete_configurations=true&delete_volumes=true&docker_cleanup=true`

### Database Lifecycle

| Endpoint | Description |
|----------|-------------|
| `GET /databases/{uuid}/start` | Start database |
| `GET /databases/{uuid}/stop` | Stop database |
| `GET /databases/{uuid}/restart` | Restart database |

### Database Backups

**GET /databases/{uuid}/backups**
→ `[{ uuid, frequency, enabled, s3_storage_uuid, ... }]`

**POST /databases/{uuid}/backups**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `frequency` | string | yes | Cron expression (e.g. `"0 2 * * *"`) |
| `enabled` | boolean | no | Enable schedule (default: true) |
| `save_s3` | boolean | no | Save to S3 |
| `s3_storage_uuid` | string | no | S3 storage UUID |
| `number_of_backups_locally` | integer | no | Local retention count |

**PATCH /databases/{uuid}/backups/{backup_uuid}**
Update backup schedule (same fields).

**DELETE /databases/{uuid}/backups/{backup_uuid}**
Remove backup configuration.

**GET /databases/{uuid}/backups/{backup_uuid}/executions**
→ `[{ uuid, status, size, created_at }]`

**DELETE /databases/{uuid}/backups/{backup_uuid}/executions/{exec_uuid}**
Delete specific backup file.

---

## 4. Services

### GET /services
List all services.
**Response:** `[{ uuid, name, status, ... }]`

### POST /services
Create a service (one-click template or custom compose).

**Method 1: One-Click Template**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `type` | string | yes | Template ID (e.g. `"gitea-with-mysql"`, `"wordpress"`, `"plausible"`) |
| `name` | string | yes | Service name |
| `project_uuid` | string | yes | Parent project UUID |
| `environment_name` | string | yes | Environment name |
| `server_uuid` | string | yes | Server UUID |
| `instant_deploy` | boolean | no | Deploy immediately |

**Method 2: Custom Docker Compose**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `docker_compose_raw` | string | yes | Base64-encoded Docker Compose YAML |
| `name` | string | yes | Service name |
| `project_uuid` | string | yes | Parent project UUID |
| `environment_name` | string | yes | Environment name |
| `server_uuid` | string | yes | Server UUID |
| `instant_deploy` | boolean | no | Deploy immediately |

**Common optional fields:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `description` | string | Service description |
| `urls` | object | Map container names to domains: `{ "web": "https://app.example.com" }` |
| `force_domain_override` | boolean | Bypass domain conflict detection |

**Response:** `201 { uuid, ... }`

### GET /services/{uuid}
Full service details including `docker_compose_raw`.

### PATCH /services/{uuid}
Update service. **Updatable:** `name`, `description`, `docker_compose_raw` (base64), `urls`

### DELETE /services/{uuid}
Delete service and all containers.

### Service Lifecycle

| Endpoint | Description |
|----------|-------------|
| `GET /services/{uuid}/start` | Start all containers |
| `GET /services/{uuid}/stop` | Stop all containers |
| `GET /services/{uuid}/restart` | Restart all containers |

### Service Environment Variables

Same pattern as applications:
- `GET /services/{uuid}/envs`
- `POST /services/{uuid}/envs` → `{ key, value, is_build_time }`
- `PATCH /services/{uuid}/envs/bulk` → `[{ key, value }, ...]`
- `PATCH /services/{uuid}/envs` → `{ uuid, key, value }`
- `DELETE /services/{uuid}/envs/{env_uuid}`

---

## 5. Projects

### GET /projects
→ `[{ uuid, name, description, environments: [...] }]`

### POST /projects
Body: `{ "name": "my-project", "description": "optional" }`
**Response:** `201 { uuid, ... }`

### GET /projects/{uuid}
Full project with environments.

### PATCH /projects/{uuid}
**Updatable:** `name`, `description`

### DELETE /projects/{uuid}
Delete project and all child environments/resources.

### GET /projects/{uuid}/environments
→ `[{ uuid, name, project_uuid }]`

### POST /projects/{uuid}/environments
Body: `{ "name": "staging" }`

### GET /projects/{uuid}/{env_name_or_uuid}
Get specific environment with its resources.

### DELETE /projects/{uuid}/environments/{env_name_or_uuid}
Delete environment and all its resources.

---

## 6. Deployments

### GET /deploy
Trigger deployment.

| Query Parameter | Type | Description |
|----------------|------|-------------|
| `uuid` | string | Application UUID to deploy |
| `tag` | string | Deploy all apps with this tag |
| `force` | boolean | Force redeploy (default: false) |

Use either `uuid` OR `tag`, not both.
**Response:** `{ message, deployment_uuid }` or `429` if rate limited.

### GET /deployments
List recent/running deployments.
→ `[{ uuid, status, application_uuid, created_at }]`

### GET /deployments/{uuid}
Full deployment details.
→ `{ uuid, status, logs, started_at, finished_at }`

**Status values:** `queued`, `in_progress`, `finished`, `failed`, `cancelled-by-user`

### POST /deployments/{uuid}/cancel
Cancel an active deployment. Only works on `queued` or `in_progress` deployments.

### GET /deployments/applications/{uuid}
Deployment history for a specific application.

---

## 7. Resources

### GET /resources
List ALL resources across the team (applications, databases, services).

---

## 8. Teams

### GET /teams
List all teams for the authenticated user.

### GET /teams/current
Current active team details.

### GET /teams/current/members
Members of the current team.

### GET /teams/{id}
Team by ID.

### GET /teams/{id}/members
Members of a specific team.

---

## 9. Private Keys

### GET /private-keys
→ `[{ uuid, name, description, is_git_related }]`

### POST /private-keys

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | yes | Key name |
| `private_key` | string | yes | PEM-encoded private key |
| `description` | string | no | Description |
| `is_git_related` | boolean | no | Used for git operations |

### GET /private-keys/{uuid}
Full key details (private key content excluded in response).

### PATCH /private-keys/{uuid}
**Updatable:** `name`, `description`, `private_key`

### DELETE /private-keys/{uuid}
Delete private key. Fails if key is in use by a server.

---

## 10. System

### GET /version
→ `"4.0.0-beta.463"` (plain text)

### GET /api/health (root, not under /api/v1)
→ `"OK"`

---

## HTTP Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Parse response |
| 201 | Created | Parse UUID from response |
| 400 | Invalid token | Check/regenerate API token |
| 401 | Unauthenticated | Token missing or expired |
| 404 | Not found | Check UUID is correct |
| 409 | Domain conflict | Use `force_domain_override: true` or change domain |
| 422 | Validation error | Check `errors` field for details |
| 429 | Rate limited | Wait `Retry-After` seconds (usually 60) |

---

## Common Multi-Step Workflows

### Deploy a new app from Docker image
```
1. GET /servers                              → pick server_uuid
2. GET /projects                             → pick project_uuid (or create one)
3. POST /applications/dockerimage            → get app uuid
   { server_uuid, project_uuid, environment_name: "production",
     name: "my-app", docker_registry_image_name: "nginx",
     ports_exposes: "80", instant_deploy: true }
4. GET /applications/{uuid}                  → verify status
```

### Deploy a new app from git repo
```
1. GET /servers                              → pick server_uuid
2. GET /projects                             → pick project_uuid
3. POST /applications/public                 → get app uuid
   { server_uuid, project_uuid, environment_name: "production",
     name: "my-api", git_repository: "https://github.com/user/repo",
     git_branch: "main", build_pack: "nixpacks",
     ports_exposes: "3000", instant_deploy: true }
4. GET /deployments                          → monitor deployment
```

### Create a full stack (app + database)
```
1. GET /servers                              → server_uuid
2. POST /projects { name: "my-project" }     → project_uuid
3. POST /databases/postgresql                → db_uuid
   { server_uuid, project_uuid, environment_name: "production",
     name: "my-db", postgres_user: "app", postgres_password: "...",
     postgres_db: "myapp", instant_deploy: true }
4. GET /databases/{db_uuid}                  → get connection details
5. POST /applications/public                 → app_uuid
   { server_uuid, project_uuid, environment_name: "production",
     name: "my-api", git_repository: "...", git_branch: "main",
     instant_deploy: true }
6. POST /applications/{app_uuid}/envs        → set DATABASE_URL
   { key: "DATABASE_URL", value: "postgresql://app:...@{db_host}:5432/myapp" }
7. GET /applications/{app_uuid}/restart      → restart to pick up env
```

### Set up automated backups
```
1. GET /databases                            → pick db_uuid
2. POST /databases/{uuid}/backups
   { frequency: "0 2 * * *", enabled: true,
     number_of_backups_locally: 7 }
3. GET /databases/{uuid}/backups             → verify configuration
```

### Migrate an app to another server
```
1. GET /applications/{uuid}                  → save current config
2. GET /applications/{uuid}/envs             → save env vars
3. POST /applications/dockerimage (or /public) on new server → new_uuid
4. PATCH /applications/{new_uuid}/envs/bulk  → restore env vars
5. GET /applications/{new_uuid}/start        → deploy
6. Verify, then DELETE /applications/{old_uuid}
```

### Bulk restart all apps on a server
```
1. GET /servers/{uuid}/resources             → list all apps
2. For each app: GET /applications/{uuid}/restart
```

### Domain management
```
1. GET /servers/{uuid}/domains               → list all domains
2. PATCH /applications/{uuid}                → update fqdn
   { fqdn: "https://new-domain.example.com" }
3. GET /applications/{uuid}/restart          → apply changes
```
