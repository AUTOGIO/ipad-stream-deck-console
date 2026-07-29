#!/bin/zsh
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

app_key="${1:-}"
[[ -n "$app_key" ]] || { sd_log_error "Usage: open-app-key.zsh <app_key>"; exit 1; }
sd_launch_configured_app "$SD_APPS_JSON" "$app_key"
