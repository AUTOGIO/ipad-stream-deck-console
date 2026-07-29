#!/bin/zsh
# scripts/workspace/reset-daily-layout.zsh — reposition windows without full relaunch

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

sd_log_info "Reset Daily Layout — begin"

layout_file="$(zsh "${SD_ROOT}/scripts/system/select-layout.zsh")"
layout_mode="$(/usr/bin/python3 - "$layout_file" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as fh:
    print(json.load(fh).get("mode", "safe_layout"))
PY
)"

# Launch only missing essentials referenced in layout (no restarts).
/usr/bin/python3 - "$layout_file" "$SD_APPS_JSON" <<'PY' | while IFS= read -r app_key; do
import json, sys
layout = json.load(open(sys.argv[1], encoding="utf-8"))
apps = json.load(open(sys.argv[2], encoding="utf-8")).get("apps", {})
for win in layout.get("windows", []):
    name = win.get("app", "")
    for key, info in apps.items():
        if info.get("name") == name:
            print(key)
            break
PY
  sd_launch_if_installed "$app_key" || true
done

/bin/sleep 0.8

hs_layout="$(/usr/bin/python3 - "$layout_file" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as fh:
    print(json.load(fh).get("hammerspoon_layout", "command_center"))
PY
)"
sd_apply_hammerspoon_layout "$hs_layout"

sd_log_info "Reset Daily Layout — complete (${layout_mode})"
sd_notify "Reset Layout" "Daily layout restored (${layout_mode})."
sd_show_dialog "Reset Daily Layout" "Layout restored: ${layout_mode}"
