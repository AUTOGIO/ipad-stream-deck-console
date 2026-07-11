#!/bin/zsh
# scripts/workspace/ai-engineering.zsh — launch AI Engineering workspace (apps only)

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

project_path="$(sd_load_path "$SD_PATHS_JSON" "ai_engineering_project")"
cursor_info="$(sd_load_app "$SD_APPS_JSON" "cursor")"
IFS='|' read -r _ _ cursor_path <<<"$cursor_info"

sd_log_info "Activating AI Engineering workspace"

sd_launch_configured_app "$SD_APPS_JSON" "terminal" || sd_log_warn "Terminal launch failed"
sd_launch_configured_app "$SD_APPS_JSON" "chatgpt" || sd_log_warn "ChatGPT launch failed"
sd_open_in_cursor "$project_path" "$cursor_path" || sd_log_warn "Cursor project launch failed"
sd_launch_configured_app "$SD_APPS_JSON" "obsidian" || sd_log_warn "Obsidian launch failed"
sd_launch_configured_app "$SD_APPS_JSON" "activitywatch" || sd_log_warn "ActivityWatch launch failed"

sd_log_info "AI Engineering workspace activation complete"
sd_show_dialog "AI Engineering Workspace" "Launched:\n• Terminal\n• ChatGPT\n• Cursor (AI_Engineering_OS)\n• Obsidian\n• ActivityWatch"
