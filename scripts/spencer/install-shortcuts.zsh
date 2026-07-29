#!/bin/zsh
# scripts/spencer/install-shortcuts.zsh — open Spencer .shortcut files for import into Shortcuts.app
#
# Double-click / Add each shortcut when Shortcuts prompts. Existing "Start My Day" is reused.

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

python3 "${SD_ROOT}/scripts/spencer/generate-shortcuts.py"

dir="${SD_ROOT}/shortcuts/spencer"
count=0
for f in "${dir}"/*.shortcut(N); do
  sd_log_info "Opening for import: $(basename "$f")"
  /usr/bin/open "$f"
  count=$((count + 1))
  /bin/sleep 0.8
done

msg="Opened ${count} Spencer shortcut file(s) in Shortcuts.\n\nFor each prompt, click Add Shortcut.\nReuse your existing \"Start My Day\" shortcut for START_MY_DAY.\n\nThen press Stream Deck Spencer buttons."
sd_log_info "$msg"
sd_show_dialog "Spencer Shortcuts" "$msg"
sd_notify "Spencer Shortcuts" "Opened ${count} shortcut(s) for import"
