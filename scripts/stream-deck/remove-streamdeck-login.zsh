#!/bin/zsh
# scripts/stream-deck/remove-streamdeck-login.zsh — rollback Stream Deck login configuration

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

sd_log_info "Removing Stream Deck login configuration"

/usr/bin/osascript <<'APPLESCRIPT'
tell application "System Events"
  repeat with itemName in (name of every login item)
    if itemName contains "Stream Deck" or itemName contains "Elgato Stream Deck" then
      delete login item itemName
    end if
  end repeat
end tell
APPLESCRIPT

agent_plist="${HOME}/Library/LaunchAgents/com.autogio.streamdeck.login.plist"
if [[ -f "$agent_plist" ]]; then
  /bin/launchctl bootout "gui/$(/usr/bin/id -u)" "$agent_plist" 2>/dev/null || true
  /bin/rm -f "$agent_plist"
  sd_log_info "Removed LaunchAgent: ${agent_plist}"
fi

sd_notify "Stream Deck Login" "Login configuration removed."
print -r -- "OK  Stream Deck login rollback complete"
