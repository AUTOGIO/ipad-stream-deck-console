#!/bin/zsh
# Set current project from the configured projects map (or AppleScript picker).
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

if [[ "${SD_SKIP_DIALOGS:-}" == "1" && -n "${1:-}" ]]; then
  project_key="$1"
  project_path="$(sd_json_get "$SD_CONFIG_JSON" "projects.${project_key}" 2>/dev/null || true)"
  if [[ -z "$project_path" || ! -d "$project_path" ]]; then
    sd_log_error "Unknown project key: ${project_key}"
    exit 1
  fi
  sd_set_active_project "$project_path"
  /usr/bin/python3 - "$SD_CONFIG_JSON" "$project_path" <<'PY'
import json, sys
path, project = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as fh:
    data = json.load(fh)
data["active_project"] = project
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PY
  sd_notify "Current Project" "Set $(/usr/bin/basename "$project_path")"
  exit 0
fi

# Interactive: reuse project selector AppleScript when available.
selector="${SD_ROOT}/applescript/project-selector.applescript"
if [[ -f "$selector" ]]; then
  /usr/bin/osascript "$selector" || true
  sd_notify "Current Project" "Picker launched"
  exit 0
fi

sd_log_error "No project selector available"
exit 1
