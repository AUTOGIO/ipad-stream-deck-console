#!/bin/zsh
# scripts/spencer/restore-layout.zsh — restore a Spencer desktop layout (Start My Day pattern)
#
# Usage: restore-layout.zsh <LAYOUT_NAME>
# Matches the Apple Shortcut shell body: open Spencer, wait for CLI, restore with apps.

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

layout_name="${1:-}"
if [[ -z "$layout_name" ]]; then
  sd_log_error "Usage: restore-layout.zsh <LAYOUT_NAME>"
  exit 1
fi

spencer_cli="/Applications/Spencer.app/Contents/MacOS/SpencerCLI"
if [[ ! -x "$spencer_cli" ]]; then
  if [[ -x "${HOME}/.local/bin/spencer" ]]; then
    spencer_cli="${HOME}/.local/bin/spencer"
  elif command -v spencer >/dev/null 2>&1; then
    spencer_cli="$(command -v spencer)"
  else
    sd_log_error "Spencer CLI not found"
    sd_show_dialog "Spencer" "Spencer CLI not found.\nInstall Spencer.app first."
    exit 1
  fi
fi

sd_log_info "Restoring Spencer layout: ${layout_name}"
/usr/bin/open -a Spencer >/dev/null 2>&1 || true

ready=0
for _ in {1..20}; do
  if "$spencer_cli" --list >/dev/null 2>&1; then
    ready=1
    break
  fi
  /bin/sleep 0.5
done

if (( ready == 0 )); then
  sd_log_error "Spencer CLI did not become ready"
  sd_show_dialog "Spencer" "Spencer CLI did not become ready.\nIs Spencer.app installed and allowed?"
  exit 1
fi

if ! "$spencer_cli" --restore "$layout_name" --launch-apps=true; then
  sd_log_error "Spencer restore failed for ${layout_name}"
  sd_show_dialog "Spencer" "Failed to restore layout:\n${layout_name}"
  exit 1
fi

sd_notify "Spencer" "Restored ${layout_name}"
sd_show_dialog "Spencer" "Restored layout:\n${layout_name}"
