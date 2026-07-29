#!/bin/zsh
# Restart one configured cloud AI application (never force-kill; one attempt).
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

apps=("${(@f)$(sd_json_list "$SD_CONFIG_JSON" "ai.restart_apps")}")
if (( ${#apps[@]} == 0 )); then
  sd_log_error "No ai.restart_apps configured"
  sd_show_dialog "Restart AI" "No restartable AI apps configured."
  exit 1
fi

labels=()
for key in "${apps[@]}"; do
  info="$(sd_load_app "$SD_APPS_JSON" "$key" 2>/dev/null || true)"
  [[ -n "$info" ]] || continue
  IFS='|' read -r name _ _ <<<"$info"
  labels+=("$name|$key")
done

if (( ${#labels[@]} == 0 )); then
  sd_show_dialog "Restart AI" "No installed AI apps found to restart."
  exit 1
fi

selected_key=""
selected_name=""
if [[ "${SD_SKIP_DIALOGS:-}" == "1" ]]; then
  selected_key="${1:-${apps[1]}}"
  info="$(sd_load_app "$SD_APPS_JSON" "$selected_key")"
  IFS='|' read -r selected_name _ _ <<<"$info"
else
  list_items="$(printf '"%s", ' "${labels[@]%%|*}" | /usr/bin/sed 's/, $//')"
  choice="$(/usr/bin/osascript <<EOF
set theList to {${list_items}}
set theChoice to choose from list theList with prompt "Restart which AI application?" with title "Restart AI" without multiple selections allowed
if theChoice is false then return ""
item 1 of theChoice
EOF
)" || choice=""
  [[ -n "$choice" ]] || exit 0
  for entry in "${labels[@]}"; do
    name="${entry%%|*}"
    key="${entry##*|}"
    if [[ "$name" == "$choice" ]]; then
      selected_name="$name"
      selected_key="$key"
      break
    fi
  done
fi

[[ -n "$selected_key" ]] || exit 1

if ! sd_confirm_dialog "Restart AI" "Quit and reopen ${selected_name}?\nOne attempt. No force-kill."; then
  sd_log_info "Restart cancelled for ${selected_name}"
  exit 0
fi

/usr/bin/osascript -e "tell application \"${selected_name}\" to quit" >/dev/null 2>&1 || true
for _ in {1..20}; do
  if ! sd_process_running "$selected_name"; then
    break
  fi
  /bin/sleep 0.5
done

if sd_process_running "$selected_name"; then
  sd_log_error "Application refused to quit: ${selected_name}"
  sd_show_dialog "Restart AI" "${selected_name} refused to quit.\nStopped without force-kill."
  exit 1
fi

if ! sd_launch_configured_app "$SD_APPS_JSON" "$selected_key"; then
  sd_show_dialog "Restart AI" "Failed to reopen ${selected_name}."
  exit 1
fi

/bin/sleep 1
if sd_process_running "$selected_name"; then
  sd_notify "Restart AI" "${selected_name} reopened"
  sd_show_dialog "Restart AI" "Application reopened:\n${selected_name}"
  sd_log_info "Restarted AI app: ${selected_key}"
  exit 0
fi

sd_show_dialog "Restart AI" "Reopened ${selected_name}, but process not confirmed yet."
sd_log_warn "Restart launched but process not confirmed: ${selected_name}"
exit 0
