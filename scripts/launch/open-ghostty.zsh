#!/bin/zsh
# scripts/launch/open-ghostty.zsh — open Ghostty at the active Cursor project
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

# An explicit path is used by START MY DAY. The standalone Stream Deck button
# otherwise follows the unambiguous Cursor workspace, then the saved project.
project_path="${1:-}"
if [[ -z "$project_path" || ! -d "$project_path" ]]; then
  project_path="$(sd_detect_cursor_project 2>/dev/null || true)"
fi
if [[ -z "$project_path" || ! -d "$project_path" ]]; then
  project_path="$(sd_get_active_project 2>/dev/null || true)"
fi

ghostty_info="$(sd_load_app "$SD_APPS_JSON" "ghostty")"
IFS='|' read -r ghostty_name _ ghostty_path <<<"$ghostty_info"
sd_require_path "$ghostty_name" "$ghostty_path"

if [[ -n "$project_path" && -d "$project_path" ]]; then
  /usr/bin/open -na "$ghostty_path" --args "--working-directory=${project_path}"
  sd_log_info "Opened Ghostty at Cursor project: ${project_path}"
else
  /usr/bin/open -na "$ghostty_path"
  sd_log_warn "Opened Ghostty without a project directory"
fi
