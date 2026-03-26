Execute a raw API call against the Coolify server.

Usage: /api <METHOD> <PATH> [JSON_BODY]

Examples:
  /api GET /servers
  /api POST /projects '{"name":"my-project"}'
  /api PATCH /applications/abc-123 '{"name":"new-name"}'
  /api DELETE /applications/abc-123

Run: `./scripts/coolify raw <METHOD> <PATH> [BODY]`

Display the response as formatted JSON. If the call fails, show the error and suggest fixes based on the HTTP status code:
- 400: Check token validity
- 401: Token missing or expired
- 404: Resource UUID might be wrong
- 409: Domain conflict - suggest using force_domain_override
- 422: Validation error - show which fields are wrong
- 429: Rate limited - wait and retry
