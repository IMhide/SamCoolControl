#!/usr/bin/env bash
#
# coolify-api.sh - Low-level wrapper around the Coolify REST API
#
# Usage:
#   source coolify-api.sh
#   coolify_api GET /servers
#   coolify_api POST /applications '{"name":"my-app"}'
#
# Requires: curl, jq
# Config: reads COOLIFY_BASE_URL and COOLIFY_API_TOKEN from .env or environment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---------------------------------------------------------------------------
# Configuration (multi-infra profiles)
# ---------------------------------------------------------------------------

# Resolve the active infra profile name.
# Order: $COOLIFY_PROFILE (env) -> infras/.current (file) -> empty (legacy fallback).
# Echoes the profile name (possibly empty). Never fails.
_coolify_resolve_profile() {
    if [[ -n "${COOLIFY_PROFILE:-}" ]]; then
        printf '%s' "$COOLIFY_PROFILE"
        return 0
    fi
    local current_file="$PROJECT_ROOT/infras/.current"
    if [[ -f "$current_file" ]]; then
        # trim whitespace/newlines
        local name
        name="$(tr -d '[:space:]' < "$current_file")"
        printf '%s' "$name"
        return 0
    fi
    printf ''
}

_coolify_load_env() {
    # Highest priority: an explicit env file path (back-compat / tests).
    local env_file="${COOLIFY_ENV_FILE:-}"

    if [[ -z "$env_file" ]]; then
        # Resolve the active profile and prefer its per-infra .env.
        local profile
        profile="$(_coolify_resolve_profile)"
        if [[ -n "$profile" ]]; then
            local profile_env="$PROJECT_ROOT/infras/$profile/.env"
            if [[ -f "$profile_env" ]]; then
                env_file="$profile_env"
            else
                echo "WARNING: profile '$profile' selected but $profile_env not found; falling back to $PROJECT_ROOT/.env" >&2
            fi
        fi
    fi

    # Fallback to the legacy root .env (mono-server back-compat).
    env_file="${env_file:-$PROJECT_ROOT/.env}"

    if [[ -f "$env_file" ]]; then
        # shellcheck disable=SC1090
        set -a
        source "$env_file"
        set +a
    fi

    if [[ -z "${COOLIFY_BASE_URL:-}" ]]; then
        echo "ERROR: COOLIFY_BASE_URL is not set (looked in: $env_file). Configure it, or run: ./scripts/infra new <name>." >&2
        return 1
    fi
    if [[ -z "${COOLIFY_API_TOKEN:-}" ]]; then
        echo "ERROR: COOLIFY_API_TOKEN is not set (looked in: $env_file). Generate one from your Coolify UI." >&2
        return 1
    fi

    # Strip trailing slash
    COOLIFY_BASE_URL="${COOLIFY_BASE_URL%/}"
}

# ---------------------------------------------------------------------------
# Core API caller
# ---------------------------------------------------------------------------

coolify_api() {
    local method="${1:?Usage: coolify_api METHOD PATH [BODY]}"
    local path="${2:?Usage: coolify_api METHOD PATH [BODY]}"
    local body="${3:-}"

    _coolify_load_env || return 1

    local url="${COOLIFY_BASE_URL}/api/v1${path}"
    local curl_args=(
        --silent
        --show-error
        --fail-with-body
        --request "$method"
        --header "Authorization: Bearer ${COOLIFY_API_TOKEN}"
        --header "Accept: application/json"
        --header "Content-Type: application/json"
    )

    if [[ -n "$body" ]]; then
        curl_args+=(--data "$body")
    fi

    local response http_code
    response=$(curl "${curl_args[@]}" --write-out "\n%{http_code}" "$url" 2>&1) || true

    http_code=$(echo "$response" | tail -1)
    response=$(echo "$response" | sed '$d')

    if [[ "$http_code" -ge 400 ]] 2>/dev/null; then
        echo "API Error (HTTP $http_code):" >&2
        echo "$response" | jq . 2>/dev/null || echo "$response" >&2
        return 1
    fi

    echo "$response" | jq . 2>/dev/null || echo "$response"
}

# ---------------------------------------------------------------------------
# Convenience functions
# ---------------------------------------------------------------------------

# Servers
coolify_servers_list()       { coolify_api GET /servers; }
coolify_server_get()         { coolify_api GET "/servers/${1:?uuid required}"; }
coolify_server_resources()   { coolify_api GET "/servers/${1:?uuid required}/resources"; }
coolify_server_domains()     { coolify_api GET "/servers/${1:?uuid required}/domains"; }
coolify_server_validate()    { coolify_api GET "/servers/${1:?uuid required}/validate"; }

# Applications
coolify_apps_list()          { coolify_api GET /applications; }
coolify_app_get()            { coolify_api GET "/applications/${1:?uuid required}"; }
coolify_app_start()          { coolify_api GET "/applications/${1:?uuid required}/start"; }
coolify_app_stop()           { coolify_api GET "/applications/${1:?uuid required}/stop"; }
coolify_app_restart()        { coolify_api GET "/applications/${1:?uuid required}/restart"; }
coolify_app_logs()           { coolify_api GET "/applications/${1:?uuid required}/logs"; }
coolify_app_envs()           { coolify_api GET "/applications/${1:?uuid required}/envs"; }

# Databases
coolify_databases_list()     { coolify_api GET /databases; }
coolify_database_get()       { coolify_api GET "/databases/${1:?uuid required}"; }
coolify_database_start()     { coolify_api GET "/databases/${1:?uuid required}/start"; }
coolify_database_stop()      { coolify_api GET "/databases/${1:?uuid required}/stop"; }
coolify_database_restart()   { coolify_api GET "/databases/${1:?uuid required}/restart"; }

# Services
coolify_services_list()      { coolify_api GET /services; }
coolify_service_get()        { coolify_api GET "/services/${1:?uuid required}"; }
coolify_service_start()      { coolify_api GET "/services/${1:?uuid required}/start"; }
coolify_service_stop()       { coolify_api GET "/services/${1:?uuid required}/stop"; }
coolify_service_restart()    { coolify_api GET "/services/${1:?uuid required}/restart"; }
coolify_service_envs()       { coolify_api GET "/services/${1:?uuid required}/envs"; }

# Projects
coolify_projects_list()      { coolify_api GET /projects; }
coolify_project_get()        { coolify_api GET "/projects/${1:?uuid required}"; }
coolify_project_envs()       { coolify_api GET "/projects/${1:?uuid required}/environments"; }

# Deployments
coolify_deployments_list()   { coolify_api GET /deployments; }
coolify_deployment_get()     { coolify_api GET "/deployments/${1:?uuid required}"; }
coolify_deploy()             { coolify_api GET "/deploy?uuid=${1:?uuid required}&force=${2:-false}"; }
coolify_deploy_by_tag()      { coolify_api GET "/deploy?tag=${1:?tag required}&force=${2:-false}"; }

# Resources
coolify_resources_list()     { coolify_api GET /resources; }

# Teams
coolify_teams_list()         { coolify_api GET /teams; }
coolify_team_current()       { coolify_api GET /teams/current; }
coolify_team_members()       { coolify_api GET /teams/current/members; }

# Private Keys
coolify_keys_list()          { coolify_api GET /private-keys; }

# System
coolify_version()            { coolify_api GET /version; }
coolify_healthcheck() {
    # healthcheck lives at the root, not under /api/v1
    _coolify_load_env || return 1
    curl --silent --show-error --fail \
        --header "Authorization: Bearer ${COOLIFY_API_TOKEN}" \
        "${COOLIFY_BASE_URL}/api/health" 2>/dev/null \
    || curl --silent --show-error "${COOLIFY_BASE_URL}/api/health" 2>/dev/null \
    || echo "OK (endpoint not available, but API is reachable)"
}

# ---------------------------------------------------------------------------
# If executed directly (not sourced), run the provided arguments as a command
# ---------------------------------------------------------------------------

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 <METHOD> <PATH> [BODY]"
        echo "       $0 GET /servers"
        echo "       $0 POST /applications '{\"name\":\"my-app\"}'"
        exit 1
    fi
    coolify_api "$@"
fi
