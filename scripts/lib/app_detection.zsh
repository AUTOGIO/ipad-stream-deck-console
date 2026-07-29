#!/bin/zsh
# scripts/lib/app_detection.zsh — application and path detection

sd_app_installed() {
  local bundle_id="$1"
  local app_path="$2"

  if [[ -n "$app_path" && -d "$app_path" ]]; then
    return 0
  fi

  if [[ -n "$bundle_id" ]] && /usr/bin/osascript -e "id of application id \"${bundle_id}\"" >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

sd_process_running() {
  local pattern="$1"
  pgrep -if "$pattern" >/dev/null 2>&1
}

sd_json_get() {
  local file="$1"
  local query="$2"
  /usr/bin/python3 - "$file" "$query" <<'PY'
import json, sys
path, query = sys.argv[1], sys.argv[2]
with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)

def resolve(obj, key_path):
    cur = obj
    for part in key_path.split("."):
        if isinstance(cur, dict) and part in cur:
            cur = cur[part]
        else:
            return None
    return cur

value = resolve(data, query)
if value is None:
    sys.exit(1)
if isinstance(value, bool):
    print("true" if value else "false")
elif isinstance(value, (dict, list)):
    print(json.dumps(value))
else:
    print(value)
PY
}

sd_load_app() {
  local apps_json="$1"
  local app_key="$2"
  local name bundle_id path
  name="$(sd_json_get "$apps_json" "apps.${app_key}.name" 2>/dev/null || true)"
  bundle_id="$(sd_json_get "$apps_json" "apps.${app_key}.bundle_id" 2>/dev/null || true)"
  path="$(sd_json_get "$apps_json" "apps.${app_key}.path" 2>/dev/null || true)"

  if [[ -z "$name" || -z "$bundle_id" ]]; then
    return 1
  fi

  print -r -- "$name|$bundle_id|$path"
}

sd_load_path() {
  # Prefer config.json paths.* (canonical) when available; fall back to paths.json.
  local paths_json="$1"
  local path_key="$2"
  local from_config=""
  if [[ -n "${SD_CONFIG_JSON:-}" && -f "${SD_CONFIG_JSON}" ]]; then
    from_config="$(sd_json_get "$SD_CONFIG_JSON" "paths.${path_key}" 2>/dev/null || true)"
    if [[ -n "$from_config" ]]; then
      print -r -- "$from_config"
      return 0
    fi
  fi
  sd_json_get "$paths_json" "$path_key"
}
