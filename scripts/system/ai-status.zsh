#!/bin/zsh
# Read-only cloud AI / workstation readiness status.
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

reports_dir="$(sd_config_get "paths.reports_dir" 2>/dev/null || print -r -- "${SD_ROOT}/reports")"
/bin/mkdir -p "$reports_dir"
stamp="$(/bin/date '+%Y-%m-%d_%H-%M-%S')"
detail="${reports_dir}/ai-status-${stamp}.txt"
latest="${reports_dir}/ai-status-latest.txt"

lines=()
overall="OK"
error_count=0
warn_count=0

add_line() {
  lines+=("$1")
}

check_required() {
  local key="$1"
  local val
  val="$(sd_config_get "ai.required.${key}" 2>/dev/null || print -r -- "false")"
  [[ "$val" == "true" ]]
}

# Internet
if /sbin/ping -c 1 -t 2 1.1.1.1 >/dev/null 2>&1; then
  add_line "Internet: AVAILABLE"
else
  add_line "Internet: UNAVAILABLE"
  if check_required internet; then
    overall="ERROR"
    error_count=$((error_count + 1))
  else
    warn_count=$((warn_count + 1))
    [[ "$overall" == "OK" ]] && overall="WARNING"
  fi
fi

# Configured apps
while IFS= read -r app_key; do
  [[ -n "$app_key" ]] || continue
  info="$(sd_load_app "$SD_APPS_JSON" "$app_key" 2>/dev/null || true)"
  if [[ -z "$info" ]]; then
    add_line "${app_key}: NOT CONFIGURED"
    warn_count=$((warn_count + 1))
    [[ "$overall" == "OK" ]] && overall="WARNING"
    continue
  fi
  IFS='|' read -r name bundle_id path <<<"$info"
  if ! sd_app_installed "$bundle_id" "$path"; then
    add_line "${name}: NOT INSTALLED"
    if check_required "$app_key"; then
      overall="ERROR"
      error_count=$((error_count + 1))
    else
      warn_count=$((warn_count + 1))
      [[ "$overall" == "OK" ]] && overall="WARNING"
    fi
    continue
  fi
  if sd_process_running "$name"; then
    add_line "${name}: RUNNING"
  else
    add_line "${name}: INSTALLED"
  fi
done < <(sd_json_list "$SD_CONFIG_JSON" "ai.check_apps")

# Stream Deck / Hammerspoon optional process checks
if sd_process_running "Stream Deck"; then
  add_line "Stream Deck: RUNNING"
else
  add_line "Stream Deck: NOT RUNNING"
  if check_required stream_deck; then
    overall="ERROR"
  else
    [[ "$overall" == "OK" ]] && overall="WARNING"
  fi
fi

if sd_process_running "Hammerspoon"; then
  add_line "Hammerspoon: RUNNING"
else
  add_line "Hammerspoon: NOT RUNNING"
  if check_required hammerspoon; then
    overall="ERROR"
  else
    [[ "$overall" == "OK" ]] && overall="WARNING"
  fi
fi

add_line "Overall: ${overall}"

{
  print -r -- "AI Status — $(/bin/date '+%Y-%m-%d %H:%M:%S %Z')"
  print -r -- "========================================"
  for line in "${lines[@]}"; do
    print -r -- "$line"
  done
} | /usr/bin/tee "$detail" >"$latest"

summary="$(printf '%s; ' "${lines[@]}" | /usr/bin/sed 's/; $//')"
sd_notify "AI Status" "Overall: ${overall}"
sd_show_dialog "AI Status" "$(print -r -- "${lines[@]}" | /usr/bin/paste -sd '\n' -)"
sd_log_info "AI status overall=${overall} detail=${detail}"
