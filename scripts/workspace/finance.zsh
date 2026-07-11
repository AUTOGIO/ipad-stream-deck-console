#!/bin/zsh
# scripts/workspace/finance.zsh — launch Finance workspace (apps only)

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

finance_path="$(sd_load_path "$SD_PATHS_JSON" "finance_project")"
spreadsheet_key="$(sd_get_default_key "$SD_APPS_JSON" "finance_spreadsheet")"

sd_log_info "Activating Finance workspace"

sd_launch_configured_app "$SD_APPS_JSON" "$spreadsheet_key" || sd_log_warn "Spreadsheet launch failed"
sd_open_path "$finance_path" "Finance project" || sd_log_warn "Finance folder launch failed"
sd_launch_configured_app "$SD_APPS_JSON" "obsidian" || sd_log_warn "Obsidian launch failed"
sd_launch_configured_app "$SD_APPS_JSON" "chatgpt" || sd_log_warn "ChatGPT launch failed"

sd_log_info "Finance workspace activation complete"
sd_show_dialog "Finance Workspace" "Launched:\n• Spreadsheet (${spreadsheet_key})\n• Finance project folder\n• Obsidian\n• ChatGPT"
