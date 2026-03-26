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
# Configuration
# ---------------------------------------------------------------------------

_coolify_load_env() {
    local env_file="${COOLIFY_ENV_FILE:-$PROJECT_ROOT/.env}"
    if [[ -f "$env_file" ]]; then
        # shellcheck disable=SC1090
        set -a
        source "$env_file"
        set +a
    fi

    if [[ -z "${COOLIFY_BASE_URL:-}" ]]; then
        echo "ERROR: COOLIFY_BASE_URL is not set. Copy .env.example to .env and configure it." >&2
        return 1
    fi
    if [[ -z "${COOLIFY_API_TOKEN:-}" ]]; then
        echo "ERROR: COOLIFY_API_TOKEN is not set. Generate one from your Coolify UI." >&2
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
coolify_healthcheck()        { coolify_api GET /healthcheck; }

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
