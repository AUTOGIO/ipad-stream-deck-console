#!/bin/zsh
# tests/validate-config.zsh — validate config.json, apps.json, and paths.json

set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "${ROOT}/scripts/lib/common.zsh"

sd_init_logging "$ROOT"

CONFIG_JSON="${ROOT}/config/config.json"
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

sd_require_file "config.json" "$CONFIG_JSON" || exit 2
sd_require_file "apps.json" "$APPS_JSON" || exit 2
sd_require_file "paths.json" "$PATHS_JSON" || exit 2

print -r -- "Validating ipad-stream-deck-console configuration"
print -r -- "Project root: ${ROOT}"

print -r -- "--- config.json ---"
for key in version active_project; do
  value="$(sd_json_get "$CONFIG_JSON" "$key" 2>/dev/null || true)"
  if [[ -n "$value" ]]; then
    pass "config.${key} = ${value}"
  else
    fail "config.${key} missing"
  fi
done

for section in startup start_my_day layouts features; do
  if sd_json_get "$CONFIG_JSON" "$section" >/dev/null 2>&1; then
    pass "config.${section} present"
  else
    fail "config.${section} missing"
  fi
done

for layout in dual-display.json single-external.json single-builtin.json safe-layout.json; do
  if [[ -f "${ROOT}/layouts/${layout}" ]]; then
    pass "layouts/${layout}"
  else
    fail "layouts/${layout} missing"
  fi
done

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

print -r -- "--- Profile sources ---"
if [[ -f "${ROOT}/config/profiles-ipad-work.json" ]]; then
  pass "config/profiles-ipad-work.json"
else
  fail "config/profiles-ipad-work.json missing"
fi
if [[ -f "${ROOT}/config/profiles-ipad.json" ]]; then
  pass "config/profiles-ipad.json"
else
  warn "config/profiles-ipad.json missing (legacy 8x8 design; Work Console uses profiles-ipad-work.json)"
fi

print -r -- "--- Session ops scripts ---"
for script in \
  scripts/projects/open-current-project.zsh \
  scripts/projects/set-current-project.zsh \
  scripts/workspace/focus-session.zsh \
  scripts/workspace/end-session.zsh \
  scripts/system/ai-status.zsh \
  scripts/system/restart-ai.zsh \
  scripts/launch/open-chrome.zsh \
  scripts/launch/open-gmail.zsh \
  scripts/launch/open-google-drive.zsh \
  scripts/launch/open-whatsapp.zsh \
  scripts/launch/open-telegram.zsh \
  scripts/launch/open-notebooklm.zsh \
  scripts/launch/open-desktop-commander.zsh; do
  if [[ -x "${ROOT}/${script}" ]]; then
    pass "${script}"
  else
    fail "${script} missing or not executable"
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
    codex_cli)
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
    *)
      if [[ -e "$value" ]]; then
        pass "paths.${key}"
      else
        fail "paths.${key} does not exist: ${value}"
      fi
      ;;
  esac
done

print -r -- "--- Scripts (MVP) ---"
for script in \
  scripts/workspace/start-my-day.zsh \
  scripts/workspace/reset-daily-layout.zsh \
  scripts/workspace/development-workspace.zsh \
  scripts/system/detect-displays.zsh \
  scripts/system/select-layout.zsh \
  scripts/system/ensure-streamdeck-running.zsh \
  scripts/stream-deck/configure-streamdeck-login.zsh \
  scripts/stream-deck/remove-streamdeck-login.zsh \
  scripts/launch/open-codex.zsh \
  scripts/launch/open-chatgpt-atlas.zsh; do
  if [[ -x "${ROOT}/${script}" ]]; then
    pass "${script}"
  else
    fail "${script} missing or not executable"
  fi
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
