#!/bin/zsh
# Open the configured current/active project in Cursor (+ optional Terminal/Finder).
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

project_path="$(sd_get_active_project 2>/dev/null || true)"
if [[ -z "$project_path" || ! -d "$project_path" ]]; then
  sd_log_error "Current project path missing or not a directory"
  sd_show_dialog "Current Project" "No valid current project configured.\nUse SET CURRENT PROJECT or Pick."
  exit 1
fi

editor_key="$(sd_config_get "current_project.editor" 2>/dev/null || print -r -- "cursor")"
if [[ "$editor_key" != "cursor" ]]; then
  sd_log_error "Configured editor unavailable or unsupported: ${editor_key}"
  sd_show_dialog "Current Project" "Editor '${editor_key}' is not supported.\nOnly Cursor is configured."
  exit 1
fi

cursor_info="$(sd_load_app "$SD_APPS_JSON" "cursor")"
IFS='|' read -r _ _ cursor_path <<<"$cursor_info"
if [[ -z "$cursor_path" || ! -d "$cursor_path" ]]; then
  sd_log_error "Cursor is not installed"
  sd_show_dialog "Current Project" "Cursor is not installed."
  exit 1
fi

sd_open_in_cursor "$project_path" "$cursor_path"

open_terminal="$(sd_config_get "current_project.open_terminal" 2>/dev/null || print -r -- "true")"
if [[ "$open_terminal" == "true" ]]; then
  sd_launch_configured_app "$SD_APPS_JSON" "terminal" || true
  # Prefer opening a Finder/Terminal context at the project path without spawning duplicates when possible.
  /usr/bin/open -a "iTerm" "$project_path" >/dev/null 2>&1 \
    || /usr/bin/open -a "Terminal" "$project_path" >/dev/null 2>&1 \
    || true
fi

open_finder="$(sd_config_get "current_project.open_finder" 2>/dev/null || print -r -- "true")"
if [[ "$open_finder" == "true" ]]; then
  /usr/bin/open "$project_path" >/dev/null 2>&1 || true
fi

project_name="$(/usr/bin/basename "$project_path")"
sd_notify "Current Project" "Opened ${project_name}"
sd_log_info "Opened current project: ${project_path}"
