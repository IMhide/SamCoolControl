---
name: api
description: Execute a raw API call against the Coolify server. Use when the user wants a direct GET/POST/PATCH/DELETE to an arbitrary endpoint not covered by other skills.
---

# /api

Execute a raw API call against Coolify.

Usage: `/api <METHOD> <PATH> [JSON_BODY]` (optionally `--infra <name>`).

Examples:
- `/api GET /servers`
- `/api POST /projects '{"name":"my-project"}'`
- `/api PATCH /applications/abc-123 '{"domains":"https://x.example"}'`
- `/api DELETE /applications/abc-123`

Steps:
1. Resolve/confirm the active infra. For any write (`POST`/`PATCH`/`DELETE`), **confirm the target
   infra** (name + base_url) first.
2. **`Read API_REFERENCE.md`** to validate the endpoint + params if non-trivial. Build bodies with
   `jq` (`habits/global/0001`).
3. Run `./scripts/coolify raw <METHOD> <PATH> [BODY]` (add `--infra <name>` if needed).
4. Display the response as formatted JSON. On failure, explain by status code:
   - 400: malformed request / check body. 401: token missing/expired. 404: wrong UUID/path.
   - 409: domain conflict → suggest `force_domain_override:true`. 422: validation — show which
     fields are wrong (e.g. `fqdn` instead of `domains`). 429: rate limited — wait and retry.
