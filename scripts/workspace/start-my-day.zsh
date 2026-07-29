#!/bin/zsh
# scripts/workspace/start-my-day.zsh — initialize daily workspace (button-driven)

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

if [[ "$(sd_config_get "start_my_day.enabled" 2>/dev/null || print -r -- "true")" != "true" ]]; then
  sd_notify "Start My Day" "Workflow is disabled in config."
  exit 0
fi

if ! sd_acquire_lock "start-my-day" 120; then
  sd_notify "Start My Day" "Already running — please wait."
  exit 1
fi

trap 'sd_release_lock start-my-day' EXIT

sd_log_info "Start My Day — begin"
launched=0
max_apps="$(sd_config_get "start_my_day.maximum_primary_apps" 2>/dev/null || print -r -- "6")"

# Launch by exact apps.json key (skips defaults.* remapping, e.g. chatgpt → atlas).
launch_exact() {
  local app_key="$1"
  local info name bundle_id path

  if (( launched >= max_apps )); then
    sd_log_warn "App limit (${max_apps}) reached; skipping ${app_key}"
    return 0
  fi

  info="$(sd_load_app "$SD_APPS_JSON" "$app_key")" || {
    sd_log_warn "Unknown app key: ${app_key}"
    return 1
  }
  IFS='|' read -r name bundle_id path <<<"$info"

  if ! sd_app_installed "$bundle_id" "$path"; then
    sd_log_warn "Optional app not installed: ${name}"
    return 1
  fi

  if [[ -n "$path" && -d "$path" ]]; then
    sd_open_app_by_path "$path" "$name" || return 1
  else
    sd_open_app_by_bundle_id "$bundle_id" "$name" || return 1
  fi
  launched=$((launched + 1))
  return 0
}

launch_flagged() {
  local flag_key="$1"
  local app_key="$2"
  local enabled
  enabled="$(sd_config_get "start_my_day.${flag_key}" 2>/dev/null || print -r -- "false")"
  [[ "$enabled" != "true" ]] && return 0
  launch_exact "$app_key" || true
}

zsh "${SD_ROOT}/scripts/system/ensure-streamdeck-running.zsh" || sd_log_warn "Stream Deck ensure failed"

# 1) Cursor → active project. The active-project pointer is the single source
# of truth, so starting work never unexpectedly opens a maintenance repository.
if [[ "$(sd_config_get "start_my_day.open_cursor" 2>/dev/null || print -r -- "true")" == "true" ]]; then
  if (( launched >= max_apps )); then
    sd_log_warn "App limit (${max_apps}) reached; skipping cursor"
  else
    project_path="$(sd_get_active_project)"
    if [[ -n "$project_path" && -d "$project_path" ]]; then
      cursor_info="$(sd_load_app "$SD_APPS_JSON" "cursor")"
      IFS='|' read -r _ _ cursor_path <<<"$cursor_info"
      if sd_open_in_cursor "$project_path" "$cursor_path"; then
        launched=$((launched + 1))
      else
        sd_log_warn "Cursor project open failed: ${project_path}"
      fi
    else
      sd_log_warn "Active project missing: ${project_path:-<empty>}"
    fi
  fi
fi

# 2–4) Native ultrawide Command Center: Atlas, project-root Ghostty, and Notes.
launch_flagged "open_chatgpt_atlas" "chatgpt_atlas"
if [[ "$(sd_config_get "start_my_day.open_ghostty" 2>/dev/null || print -r -- "false")" == "true" ]]; then
  if (( launched < max_apps )); then
    if zsh "${SD_ROOT}/scripts/launch/open-ghostty.zsh" "${project_path:-}"; then
      launched=$((launched + 1))
    else
      sd_log_warn "Ghostty project launch failed"
    fi
  fi
fi
if [[ "$(sd_config_get "start_my_day.open_notes" 2>/dev/null || print -r -- "false")" == "true" ]]; then
  if zsh "${SD_ROOT}/scripts/launch/open-notes.zsh"; then
    launched=$((launched + 1))
  else
    sd_log_warn "Notes capture launch failed"
  fi
fi

/bin/sleep 1.5

hs_layout="$(sd_config_get "start_my_day.hammerspoon_layout" 2>/dev/null || print -r -- "command_center")"
sd_apply_hammerspoon_layout "$hs_layout"

notify_msg="Start My Day complete (${hs_layout}). Launched ${launched} apps."
sd_log_info "Start My Day — complete (launched ${launched} apps, layout ${hs_layout})"
sd_notify "Start My Day" "$notify_msg"
sd_show_dialog "Start My Day" "Layout: ${hs_layout}\nApps launched: ${launched}\n\n${notify_msg}"
