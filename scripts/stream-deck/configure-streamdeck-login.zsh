#!/bin/zsh
# scripts/stream-deck/configure-streamdeck-login.zsh — enable Stream Deck at login
# Priority: macOS Login Item (Stream Deck UI pref has no documented defaults key on 7.5)

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

app_path="$(sd_config_get "paths.stream_deck_app" 2>/dev/null || print -r -- "/Applications/Elgato Stream Deck.app")"
app_name="Elgato Stream Deck"
delay="$(sd_config_get "startup.startup_delay_seconds" 2>/dev/null || print -r -- "0")"

sd_require_path "Stream Deck app" "$app_path" || exit 1

sd_log_info "Configuring Stream Deck login launch"

# Detect duplicates
existing="$(/usr/bin/osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null || true)"
if print -r -- "$existing" | /usr/bin/grep -qi "stream deck"; then
  sd_log_info "Stream Deck login item already present"
  sd_notify "Stream Deck Login" "Login item already configured."
  exit 0
fi

/usr/bin/osascript <<APPLESCRIPT
tell application "System Events"
  set appPath to "$app_path"
  set loginNames to name of every login item
  repeat with itemName in loginNames
    if itemName contains "Stream Deck" then
      return "exists"
    end if
  end repeat
  make login item at end with properties {name:"$app_name", path:appPath, hidden:false}
end tell
APPLESCRIPT

sd_log_info "Added Login Item: ${app_name} -> ${app_path}"
sd_notify "Stream Deck Login" "Stream Deck will launch at login."

# Optional LaunchAgent only when SD_USE_LAUNCHAGENT=1
if [[ "${SD_USE_LAUNCHAGENT:-}" == "1" ]]; then
  agent_dir="${HOME}/Library/LaunchAgents"
  agent_plist="${agent_dir}/com.autogio.streamdeck.login.plist"
  log_dir="$(sd_config_get "paths.logs_dir" 2>/dev/null || print -r -- "${HOME}/Library/Logs/AUTOGIO/StreamDeck")"
  /bin/mkdir -p "$agent_dir" "$log_dir"

  /usr/bin/python3 - "$agent_plist" "$app_path" "$delay" "$log_dir" <<'PY'
import plistlib, sys
from pathlib import Path
plist_path, app_path, delay, log_dir = sys.argv[1:5]
delay = int(delay or "0")
cmd = f'sleep {delay}; /usr/bin/open -a "{app_path}"' if delay > 0 else f'/usr/bin/open -a "{app_path}"'
data = {
    "Label": "com.autogio.streamdeck.login",
    "ProgramArguments": ["/bin/zsh", "-lc", cmd],
    "RunAtLoad": True,
    "StandardOutPath": str(Path(log_dir) / "streamdeck-login.log"),
    "StandardErrorPath": str(Path(log_dir) / "streamdeck-login-error.log"),
}
Path(plist_path).write_bytes(plistlib.dumps(data))
PY
  /bin/launchctl bootout "gui/$(/usr/bin/id -u)" "$agent_plist" 2>/dev/null || true
  /bin/launchctl bootstrap "gui/$(/usr/bin/id -u)" "$agent_plist"
  sd_log_info "LaunchAgent installed: ${agent_plist}"
fi

print -r -- "OK  Stream Deck login configured via Login Item"
print -r -- "App: ${app_path}"
