#!/bin/zsh
# scripts/workspace/development-workspace.zsh — development workspace launcher

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

project_path="$(sd_config_get "active_project" 2>/dev/null || sd_load_path "$SD_PATHS_JSON" "ai_engineering_project")"
cursor_info="$(sd_load_app "$SD_APPS_JSON" "cursor")"
IFS='|' read -r _ _ cursor_path <<<"$cursor_info"

sd_log_info "Activating Development workspace"

sd_launch_configured_app "$SD_APPS_JSON" "terminal" || sd_log_warn "Terminal launch failed"
sd_open_in_cursor "$project_path" "$cursor_path" || sd_log_warn "Cursor project launch failed"
sd_launch_configured_app "$SD_APPS_JSON" "chatgpt_atlas" || sd_launch_configured_app "$SD_APPS_JSON" "chatgpt" || true

zsh "${SD_ROOT}/scripts/launch/open-codex.zsh" || sd_log_warn "Codex launch failed"

/bin/sleep 1.2
sd_apply_hammerspoon_layout "dev_console"

branch=""
if [[ -d "$project_path/.git" ]]; then
  branch="$(/usr/bin/git -C "$project_path" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
fi

msg="Development workspace ready."
[[ -n "$branch" ]] && msg="${msg}\nBranch: ${branch}"

sd_notify "Development Workspace" "$msg"
sd_show_dialog "Development Workspace" "$msg"
