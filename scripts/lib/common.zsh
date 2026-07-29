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

# Return the GitHub project represented by the one unambiguous Cursor workspace
# window. Cursor workspace titles are the real project identity; Finder aliases
# are only convenience shortcuts and must not become persisted state.
sd_detect_cursor_project() {
  local cursor_windows projects_root candidate candidate_name matches=()
  cursor_windows="$(/usr/bin/osascript <<'APPLESCRIPT' 2>/dev/null || true
tell application "System Events"
  if not (exists process "Cursor") then return ""
  tell process "Cursor" to return name of every window
end tell
APPLESCRIPT
)"
  [[ -n "$cursor_windows" ]] || return 1

  projects_root="$(sd_load_path "$SD_PATHS_JSON" "projects_root" 2>/dev/null || true)"
  [[ -d "$projects_root" ]] || return 1

  while IFS= read -r candidate; do
    [[ -n "$candidate" ]] || continue
    candidate_name="$(/usr/bin/basename "$candidate")"
    if print -r -- "$cursor_windows" | /usr/bin/grep -Fq -- "${candidate_name} (Workspace)"; then
      matches+=("$candidate")
    fi
  done < <(/usr/bin/find "$projects_root" -mindepth 1 -maxdepth 1 -type d -print | while IFS= read -r candidate; do
    /usr/bin/git -C "$candidate" rev-parse --is-inside-work-tree >/dev/null 2>&1 && print -r -- "$candidate"
  done)

  if (( ${#matches[@]} == 1 )); then
    print -r -- "${matches[1]}"
    return 0
  fi

  (( ${#matches[@]} > 1 )) && sd_log_warn "Multiple Cursor projects match open windows"
  return 1
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
typeset -g SD_CONFIG_JSON=""
typeset -g SD_APPS_JSON=""
typeset -g SD_PATHS_JSON=""
typeset -g SD_LOCK_DIR="${HOME}/.autogio/streamdeck"

sd_notify() {
  local title="$1"
  local message="$2"
  /usr/bin/osascript -e "display notification $(printf '%s' "$message" | /usr/bin/python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))') with title $(printf '%s' "$title" | /usr/bin/python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')" >/dev/null 2>&1 || true
}

sd_config_get() {
  local key="$1"
  sd_json_get "$SD_CONFIG_JSON" "$key"
}

sd_acquire_lock() {
  # Atomic lock via mkdir (TOCTOU-safe). Legacy *.lock files are cleaned if present.
  local name="$1"
  local timeout="${2:-120}"
  /bin/mkdir -p "$SD_LOCK_DIR"
  local lock_dir="${SD_LOCK_DIR}/${name}.lockdir"
  local legacy_file="${SD_LOCK_DIR}/${name}.lock"

  if [[ -f "$legacy_file" ]]; then
    local legacy_age=$(( $(/bin/date +%s) - $(/usr/bin/stat -f %m "$legacy_file") ))
    if (( legacy_age >= timeout )); then
      /bin/rm -f "$legacy_file"
    else
      sd_log_warn "Lock active: ${legacy_file} (age ${legacy_age}s)"
      return 1
    fi
  fi

  if /bin/mkdir "$lock_dir" 2>/dev/null; then
    print -r -- "$$" >"${lock_dir}/pid"
    return 0
  fi

  local age=$(( $(/bin/date +%s) - $(/usr/bin/stat -f %m "$lock_dir") ))
  if (( age < timeout )); then
    sd_log_warn "Lock active: ${lock_dir} (age ${age}s)"
    return 1
  fi
  sd_log_warn "Removing stale lock: ${lock_dir}"
  /bin/rm -rf "$lock_dir"
  if /bin/mkdir "$lock_dir" 2>/dev/null; then
    print -r -- "$$" >"${lock_dir}/pid"
    return 0
  fi
  sd_log_warn "Could not acquire lock: ${lock_dir}"
  return 1
}

sd_release_lock() {
  local name="$1"
  /bin/rm -rf "${SD_LOCK_DIR}/${name}.lockdir"
  /bin/rm -f "${SD_LOCK_DIR}/${name}.lock"
}

sd_invoke_hammerspoon() {
  local action="$1"
  shift || true
  local url="hammerspoon://operations?action=${action}"
  for arg in "$@"; do
    url="${url}&${arg}"
  done
  /usr/bin/open "$url" >/dev/null 2>&1 || {
    sd_log_warn "Hammerspoon URL failed: ${url}"
    /usr/bin/open -a "Hammerspoon" >/dev/null 2>&1 || true
  }
  sd_log_info "Invoked Hammerspoon: ${action}"
}

sd_apply_hammerspoon_layout() {
  local layout_key="$1"
  local use_hs
  use_hs="$(sd_config_get "features.use_hammerspoon" 2>/dev/null || print -r -- "true")"
  if [[ "$use_hs" != "true" ]]; then
    sd_log_info "Hammerspoon layouts disabled in config"
    return 0
  fi

  local action="apply_${layout_key}_layout"
  case "$layout_key" in
    command_center|dev_console|coding|ai_workflow|ops|writing)
      action="apply_${layout_key}_layout"
      ;;
    *)
      action="apply_command_center_layout"
      ;;
  esac

  /usr/bin/open "hammerspoon://operations?action=${action}" >/dev/null 2>&1 || {
    sd_log_warn "Hammerspoon layout URL failed; launching Hammerspoon"
    /usr/bin/open -a "Hammerspoon" >/dev/null 2>&1 || true
  }
  sd_log_info "Requested Hammerspoon layout: ${action}"
}

sd_set_active_project() {
  local project_path="$1"
  local runtime_dir
  runtime_dir="$(sd_config_get "paths.runtime_dir" 2>/dev/null || true)"
  if [[ -z "$runtime_dir" ]]; then
    runtime_dir="${HOME}/Library/Application Support/AUTOGIO/streamdeck"
  fi
  /bin/mkdir -p "$runtime_dir"
  print -r -- "$project_path" >"${runtime_dir}/active_project"
  sd_log_info "Active project set: ${project_path}"
}

sd_get_active_project() {
  local runtime_dir project_path config_project
  runtime_dir="$(sd_config_get "paths.runtime_dir" 2>/dev/null || true)"
  if [[ -n "$runtime_dir" && -f "${runtime_dir}/active_project" ]]; then
    project_path="$(<"${runtime_dir}/active_project")"
    if [[ -n "$project_path" && -d "$project_path" ]]; then
      print -r -- "$project_path"
      return 0
    fi
  fi
  config_project="$(sd_config_get "active_project" 2>/dev/null || true)"
  if [[ -n "$config_project" && -d "$config_project" ]]; then
    print -r -- "$config_project"
    return 0
  fi
  sd_load_path "$SD_PATHS_JSON" "ai_engineering_project"
}

sd_launch_if_installed() {
  local app_key="$1"
  if sd_launch_configured_app "$SD_APPS_JSON" "$app_key"; then
    return 0
  fi
  sd_log_warn "Optional app not launched: ${app_key}"
  return 1
}

sd_app_running() {
  local app_name="$1"
  /usr/bin/osascript -e "tell application \"System Events\" to (name of processes) contains \"${app_name}\"" 2>/dev/null | /usr/bin/grep -q "true"
}

sd_hide_app_by_name() {
  local app_name="$1"
  /usr/bin/osascript -e "tell application \"System Events\" to if exists process \"${app_name}\" then set visible of process \"${app_name}\" to false" >/dev/null 2>&1 || true
}

sd_quit_app_by_name() {
  local app_name="$1"
  sd_app_running "$app_name" || return 0
  /usr/bin/osascript -e "tell application \"${app_name}\" to quit" >/dev/null 2>&1 || {
    sd_log_warn "Could not request quit for ${app_name}"
    return 1
  }
  sd_log_info "Requested quit: ${app_name}"
}

sd_session_log_path() {
  local path
  path="$(sd_config_get "session.log_path" 2>/dev/null || true)"
  if [[ -z "$path" ]]; then
    path="${HOME}/Reports/WorkSessions/Daily Operations Log.md"
  fi
  print -r -- "$path"
}

sd_append_session_log() {
  local line="$1"
  local log_path
  log_path="$(sd_session_log_path)"
  /bin/mkdir -p "$(/usr/bin/dirname "$log_path")"
  if [[ ! -f "$log_path" ]]; then
    print -r -- "# Daily Work Journal" >"$log_path"
    print -r -- "" >>"$log_path"
  fi
  print -r -- "$line" >>"$log_path"
}

sd_json_list() {
  local json_file="$1"
  local key="$2"
  /usr/bin/python3 - "$json_file" "$key" <<'PY'
import json, sys
path, key = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as fh:
    data = json.load(fh)
cur = data
for part in key.split("."):
    if isinstance(cur, dict) and part in cur:
        cur = cur[part]
    else:
        sys.exit(0)
if isinstance(cur, list):
    for item in cur:
        print(item)
PY
}

# Call directly from action scripts (not inside $() — subshells drop logging globals).
sd_init_from_script() {
  local script_path="$1"
  SD_ROOT="$(sd_project_root "$script_path")"

  SD_CONFIG_JSON="${SD_ROOT}/config/config.json"
  SD_APPS_JSON="${SD_ROOT}/config/apps.json"
  SD_PATHS_JSON="${SD_ROOT}/config/paths.json"

  sd_require_file "config.json" "$SD_CONFIG_JSON" || exit 2
  sd_require_file "apps.json" "$SD_APPS_JSON" || exit 2
  sd_require_file "paths.json" "$SD_PATHS_JSON" || exit 2

  local runtime_logs
  runtime_logs="$(sd_config_get "paths.logs_dir" 2>/dev/null || true)"
  if [[ -n "$runtime_logs" ]]; then
    /bin/mkdir -p "$runtime_logs"
    SD_LOG_DIR="$runtime_logs"
    SD_LOG_FILE="${runtime_logs}/ipad-stream-deck-console.log"
  else
    sd_init_logging "$SD_ROOT"
  fi

  local runtime_dir
  runtime_dir="$(sd_config_get "paths.runtime_dir" 2>/dev/null || true)"
  if [[ -n "$runtime_dir" ]]; then
    /bin/mkdir -p "$runtime_dir"
  fi
}

# Backward-compatible init used by older scripts via $(sd_init_script).
sd_init_script() {
  local script_path="${1:-${(%):-%x}}"
  sd_init_from_script "$script_path"
  print -r -- "${SD_ROOT}|${SD_APPS_JSON}|${SD_PATHS_JSON}"
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
