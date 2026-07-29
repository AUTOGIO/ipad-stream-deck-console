#!/bin/zsh
# Start a Focus Session: duration choice, Work Focus if available, hide distractors, log.
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

profile_name="$(sd_config_get "focus.profile_name" 2>/dev/null || print -r -- "Work")"
default_duration="$(sd_config_get "focus.default_duration_minutes" 2>/dev/null || print -r -- "50")"

duration="$default_duration"
if [[ "${SD_SKIP_DIALOGS:-}" != "1" ]]; then
  choice="$(/usr/bin/osascript <<EOF
button returned of (display dialog "Focus Session duration (minutes)" with title "Focus Session" buttons {"25", "50", "90"} default button "${default_duration}")
EOF
)" || choice=""
  [[ -n "$choice" ]] && duration="$choice"
fi

# Prefer Shortcuts Focus if a matching shortcut/profile exists; never silently substitute.
focus_ok=0
if command -v shortcuts >/dev/null 2>&1; then
  if shortcuts list 2>/dev/null | /usr/bin/grep -qiE "(^|/)${profile_name}([[:space:]]|$)"; then
    shortcuts run "$profile_name" >/dev/null 2>&1 && focus_ok=1 || true
  fi
fi

if (( focus_ok == 0 )); then
  # Best-effort Control Center Focus toggle when a matching Shortcut is unavailable.
  /usr/bin/osascript -e 'tell application "System Events" to tell process "Control Center" to keystroke "d" using {control down, command down}' >/dev/null 2>&1 || true
  sd_log_warn "Focus profile '${profile_name}' not confirmed via Shortcuts; used Control Center toggle fallback"
fi

while IFS= read -r app_name; do
  [[ -n "$app_name" ]] || continue
  sd_hide_app_by_name "$app_name"
done < <(sd_json_list "$SD_CONFIG_JSON" "focus.hide_apps")

project_path="$(sd_get_active_project 2>/dev/null || true)"
project_name="none"
[[ -n "$project_path" ]] && project_name="$(/usr/bin/basename "$project_path")"

stamp="$(/bin/date '+%Y-%m-%dT%H:%M:%S%z')"
sd_append_session_log "${stamp} | FOCUS_START | duration=${duration} | project=${project_name}"

sd_apply_hammerspoon_layout "coding" || true
sd_notify "Focus Session" "${duration}m · ${project_name}"
sd_show_dialog "Focus Session" "Focus started for ${duration} minutes.\nProject: ${project_name}\nDistractors hidden (not quit)."
sd_log_info "Focus session started duration=${duration} project=${project_name}"
