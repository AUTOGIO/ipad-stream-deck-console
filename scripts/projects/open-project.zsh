#!/bin/zsh
# Open a project in Cursor and apply Hammerspoon layout.
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

project_key="${1:-}"
if [[ -z "$project_key" ]]; then
  sd_log_error "Usage: open-project.zsh <project_key>"
  exit 1
fi

project_path="$(sd_json_get "$SD_CONFIG_JSON" "projects.${project_key}" 2>/dev/null || true)"
if [[ -z "$project_path" || ! -d "$project_path" ]]; then
  sd_log_error "Unknown or missing project: ${project_key}"
  exit 1
fi

sd_set_active_project "$project_path"

cursor_info="$(sd_load_app "$SD_APPS_JSON" "cursor")"
IFS='|' read -r _ _ cursor_path <<<"$cursor_info"
sd_open_in_cursor "$project_path" "$cursor_path"

layout="$(sd_json_get "$SD_CONFIG_JSON" "project_layouts.${project_key}" 2>/dev/null || print -r -- "command_center")"
sd_apply_hammerspoon_layout "$layout"

sd_notify "Project" "Opened ${project_key}"
sd_log_info "Project launcher: ${project_key} -> ${project_path}"
