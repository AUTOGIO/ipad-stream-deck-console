#!/bin/zsh
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

status_file="$(sd_config_get "paths.hammerspoon_config" 2>/dev/null || print -r -- "${HOME}/.hammerspoon")/runtime/operations_status.json"
sd_require_file "operations_status.json" "$status_file" || exit 1

summary="$(/usr/bin/python3 - "$status_file" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as fh:
    data = json.load(fh)
overall = data.get("overall", {})
services = data.get("services", {})
lines = [
    f"Health: {overall.get('score', '?')}/100 ({overall.get('status', '?')})",
    f"n8n: {services.get('n8n', {}).get('status', '?')}",
    f"Project: {'ok' if services.get('project', {}).get('path_exists') else 'missing'}",
]
print("\n".join(lines))
PY
)"

sd_notify "System Status" "$summary"
sd_log_info "Status snapshot:\n${summary}"
