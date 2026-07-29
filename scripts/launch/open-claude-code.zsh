#!/bin/zsh
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

action_key="$(sd_get_default_key "$SD_APPS_JSON" "claude_code")"
sd_log_info "Claude Code action: ${action_key}"

case "$action_key" in
  claude_desktop)
    sd_launch_configured_app "$SD_APPS_JSON" "claude"
    ;;
  cursor_ai_engineering)
    project_path="$(sd_load_path "$SD_PATHS_JSON" "ai_engineering_project")"
    cursor_info="$(sd_load_app "$SD_APPS_JSON" "cursor")"
    IFS='|' read -r _ _ cursor_path <<<"$cursor_info"
    sd_open_in_cursor "$project_path" "$cursor_path"
    ;;
  codex_cli)
    terminal_key="$(sd_get_default_key "$SD_APPS_JSON" "terminal")"
    sd_launch_configured_app "$SD_APPS_JSON" "$terminal_key"
    codex_cli="$(sd_load_path "$SD_PATHS_JSON" "codex_cli")"
    sd_require_path "codex CLI" "$codex_cli" || exit 1
    /usr/bin/osascript <<APPLESCRIPT
tell application "System Events"
  keystroke "cd $(printf '%s' "$SD_ROOT" | sed 's/"/\\"/g') && $(printf '%s' "$codex_cli")"
  key code 36
end tell
APPLESCRIPT
    sd_log_info "Launched codex CLI in terminal"
    ;;
  *)
    sd_log_error "Unknown claude_code action: ${action_key}"
    exit 1
    ;;
esac
