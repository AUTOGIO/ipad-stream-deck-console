#!/bin/zsh
# scripts/lib/common.zsh — shared helpers for ipad-stream-deck-console

set -euo pipefail

# Ensure standard macOS paths are available when launched from Stream Deck or Shortcuts.
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"

sd_project_root() {
  local caller_path="${1:-${(%):-%x}}"
  local script_dir
  script_dir="$(cd "$(dirname "$caller_path")" && pwd)"
  cd "${script_dir}/../.." && pwd
}

sd_source_libs() {
  local root="$1"
  source "${root}/scripts/lib/logging.zsh"
  source "${root}/scripts/lib/app_detection.zsh"
}

sd_require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    sd_log_error "Required command not found: ${cmd}"
    return 1
  fi
}

sd_require_path() {
  local label="$1"
  local target="$2"
  if [[ -z "$target" || ! -e "$target" ]]; then
    sd_log_error "Required path missing (${label}): ${target:-<empty>}"
    return 1
  fi
}

sd_require_file() {
  local label="$1"
  local target="$2"
  if [[ -z "$target" || ! -f "$target" ]]; then
    sd_log_error "Required file missing (${label}): ${target:-<empty>}"
    return 1
  fi
}

sd_open_app_by_bundle_id() {
  local bundle_id="$1"
  local app_name="${2:-Application}"

  if /usr/bin/open -b "$bundle_id" >/dev/null 2>&1; then
    sd_log_info "Opened ${app_name} (${bundle_id})"
    return 0
  fi

  sd_log_error "Failed to open ${app_name} (${bundle_id})"
  return 1
}

sd_open_app_by_path() {
  local app_path="$1"
  local app_name="${2:-Application}"

  sd_require_path "$app_name" "$app_path" || return 1
  /usr/bin/open "$app_path"
  sd_log_info "Opened ${app_name} at ${app_path}"
}

sd_open_path() {
  local target="$1"
  local label="${2:-Path}"

  sd_require_path "$label" "$target" || return 1
  /usr/bin/open "$target"
  sd_log_info "Opened ${label}: ${target}"
}

sd_open_in_cursor() {
  local project_path="$1"
  local cursor_app="${2:-/Applications/Cursor.app}"

  sd_require_path "Cursor project" "$project_path" || return 1
  sd_require_path "Cursor app" "$cursor_app" || return 1
  /usr/bin/open -a "$cursor_app" "$project_path"
  sd_log_info "Opened Cursor project: ${project_path}"
}

sd_show_dialog() {
  [[ "${SD_SKIP_DIALOGS:-}" == "1" ]] && return 0
  local title="$1"
  local message="$2"
  /usr/bin/osascript -e "display dialog $(printf '%s' "$message" | /usr/bin/python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))') with title $(printf '%s' "$title" | /usr/bin/python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))') buttons {\"OK\"} default button \"OK\"" >/dev/null 2>&1 || true
}

sd_confirm_dialog() {
  [[ "${SD_SKIP_DIALOGS:-}" == "1" ]] && return 0
  local title="$1"
  local message="$2"
  local result
  result="$(/usr/bin/osascript -e "button returned of (display dialog $(printf '%s' "$message" | /usr/bin/python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))') with title $(printf '%s' "$title" | /usr/bin/python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))') buttons {\"Cancel\", \"Continue\"} default button \"Continue\" cancel button \"Cancel\")" 2>/dev/null || true)"
  [[ "$result" == "Continue" ]]
}

typeset -g SD_ROOT=""
typeset -g SD_APPS_JSON=""
typeset -g SD_PATHS_JSON=""

# Call directly from action scripts (not inside $() — subshells drop logging globals).
sd_init_from_script() {
  local script_path="$1"
  SD_ROOT="$(sd_project_root "$script_path")"
  sd_init_logging "$SD_ROOT"

  SD_APPS_JSON="${SD_ROOT}/config/apps.json"
  SD_PATHS_JSON="${SD_ROOT}/config/paths.json"

  sd_require_file "apps.json" "$SD_APPS_JSON" || exit 2
  sd_require_file "paths.json" "$SD_PATHS_JSON" || exit 2
}

sd_get_default_key() {
  local apps_json="$1"
  local key="$2"
  sd_json_get "$apps_json" "defaults.${key}"
}

sd_resolve_app_key() {
  local apps_json="$1"
  local app_key="$2"
  local default_key
  default_key="$(sd_get_default_key "$apps_json" "$app_key" 2>/dev/null || true)"
  if [[ -n "$default_key" ]]; then
    print -r -- "$default_key"
  else
    print -r -- "$app_key"
  fi
}

sd_launch_configured_app() {
  local apps_json="$1"
  local app_key="$2"
  local resolved_key info name bundle_id path

  resolved_key="$(sd_resolve_app_key "$apps_json" "$app_key")"
  info="$(sd_load_app "$apps_json" "$resolved_key")" || {
    sd_log_error "Unknown app key: ${app_key} (resolved: ${resolved_key})"
    return 1
  }

  IFS='|' read -r name bundle_id path <<<"$info"
  if sd_app_installed "$bundle_id" "$path"; then
    if [[ -n "$path" && -d "$path" ]]; then
      sd_open_app_by_path "$path" "$name"
    else
      sd_open_app_by_bundle_id "$bundle_id" "$name"
    fi
    return 0
  fi

  sd_log_error "Application not installed: ${name}"
  return 1
}

# Load sibling libraries when common.zsh is sourced.
if [[ -n "${ZSH_VERSION:-}" ]]; then
  _SD_LIB_DIR="${0:A:h}"
else
  _SD_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
source "${_SD_LIB_DIR}/logging.zsh"
source "${_SD_LIB_DIR}/app_detection.zsh"
