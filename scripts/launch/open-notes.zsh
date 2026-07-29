#!/bin/zsh
# Open the persistent native capture note used by Command Center.
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

/usr/bin/osascript <<'APPLESCRIPT'
tell application "Notes"
  activate
  if not (exists folder "AUTOGIO") then
    make new folder with properties {name:"AUTOGIO"}
  end if
  tell folder "AUTOGIO"
    set matchingNotes to every note whose name is "Command Center Inbox"
    if (count of matchingNotes) is 0 then
      set captureNote to make new note with properties {name:"Command Center Inbox", body:"<h1>Command Center Inbox</h1><p><b>Next action</b></p><p><br></p><p><b>Notes</b></p><p><br></p>"}
    else
      set captureNote to item 1 of matchingNotes
    end if
    show captureNote
  end tell
end tell
APPLESCRIPT

sd_log_info "Opened Apple Notes capture note: Command Center Inbox"
sd_notify "Notes" "Command Center Inbox"
