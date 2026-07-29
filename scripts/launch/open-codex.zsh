#!/bin/zsh
# scripts/launch/open-codex.zsh — open the configured Codex CLI in the terminal

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

codex_cli="$(sd_config_get "paths.codex_cli" 2>/dev/null || sd_load_path "$SD_PATHS_JSON" "codex_cli")"
sd_launch_configured_app "$SD_APPS_JSON" "terminal" || exit 1
sd_require_path "codex CLI" "$codex_cli" || exit 1

/usr/bin/osascript <<APPLESCRIPT
tell application "System Events"
  keystroke "cd $(printf '%s' "$SD_ROOT" | sed 's/"/\\"/g') && $(printf '%s' "$codex_cli")"
  key code 36
end tell
APPLESCRIPT
sd_log_info "Launched Codex CLI"
