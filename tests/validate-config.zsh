#!/bin/zsh
# tests/validate-config.zsh — validate apps.json and paths.json against this Mac

set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "${ROOT}/scripts/lib/common.zsh"

sd_init_logging "$ROOT"

APPS_JSON="${ROOT}/config/apps.json"
PATHS_JSON="${ROOT}/config/paths.json"

errors=0
warnings=0
checked=0

pass() {
  print -r -- "PASS  $1"
  checked=$((checked + 1))
}

fail() {
  print -r -- "FAIL  $1" >&2
  sd_log_error "$1"
  errors=$((errors + 1))
  checked=$((checked + 1))
}

warn() {
  print -r -- "WARN  $1"
  sd_log_warn "$1"
  warnings=$((warnings + 1))
}

sd_require_file "apps.json" "$APPS_JSON" || exit 2
sd_require_file "paths.json" "$PATHS_JSON" || exit 2

print -r -- "Validating ipad-stream-deck-console configuration"
print -r -- "Project root: ${ROOT}"
print -r -- "--- Apps ---"

app_keys=("${(@f)$(/usr/bin/python3 - "$APPS_JSON" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as fh:
    data = json.load(fh)
for key in sorted(data.get("apps", {})):
    print(key)
PY
)}")

for key in "${app_keys[@]}"; do
  info="$(sd_load_app "$APPS_JSON" "$key" || true)"
  if [[ -z "$info" ]]; then
    fail "apps.${key} is missing required fields"
    continue
  fi

  IFS='|' read -r name bundle_id path <<<"$info"
  if sd_app_installed "$bundle_id" "$path"; then
    pass "apps.${key} (${name})"
  else
    fail "apps.${key} (${name}) not installed"
  fi
done

print -r -- "--- Paths ---"

path_keys=("${(@f)$(/usr/bin/python3 - "$PATHS_JSON" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as fh:
    data = json.load(fh)
for key in sorted(data):
    print(key)
PY
)}")

for key in "${path_keys[@]}"; do
  value="$(sd_load_path "$PATHS_JSON" "$key" 2>/dev/null || true)"
  if [[ -z "$value" ]]; then
    fail "paths.${key} is empty"
    continue
  fi

  case "$key" in
    codex_cli|ollama_cli)
      if [[ -x "$value" ]]; then
        pass "paths.${key}"
      else
        warn "paths.${key} missing or not executable: ${value}"
      fi
      ;;
    logs_dir|reports_dir|backups_dir)
      /bin/mkdir -p "$value"
      pass "paths.${key}"
      ;;
    obsidian_ai_vault_name)
      if [[ -n "$value" ]]; then
        pass "paths.${key} (label)"
      else
        fail "paths.${key} is empty"
      fi
      ;;
    *)
      if [[ -e "$value" ]]; then
        pass "paths.${key}"
      else
        fail "paths.${key} does not exist: ${value}"
      fi
      ;;
  esac
done

print -r -- "--- Defaults ---"
for default_key in chatgpt terminal claude_code finance_spreadsheet; do
  value="$(sd_get_default_key "$APPS_JSON" "$default_key" 2>/dev/null || true)"
  if [[ -n "$value" ]]; then
    pass "defaults.${default_key} = ${value}"
  else
    warn "defaults.${default_key} is not set"
  fi
done

print -r -- "--- Summary ---"
print -r -- "Checked: ${checked}"
print -r -- "Errors:  ${errors}"
print -r -- "Warnings:${warnings}"

if (( errors > 0 )); then
  exit 1
fi

exit 0
