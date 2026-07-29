#!/bin/zsh
# scripts/system/ensure-streamdeck-running.zsh — launch Stream Deck if not running

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

app_path="$(sd_config_get "paths.stream_deck_app" 2>/dev/null || print -r -- "/Applications/Elgato Stream Deck.app")"

if sd_process_running "Stream Deck"; then
  sd_log_info "Stream Deck already running"
  exit 0
fi

if [[ ! -d "$app_path" ]]; then
  sd_log_error "Stream Deck app not found: ${app_path}"
  exit 1
fi

/usr/bin/open -a "$app_path"
sd_log_info "Launched Stream Deck"
sd_notify "Stream Deck" "Stream Deck is starting…"
exit 0
