#!/bin/zsh
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

sd_log_info "Activating Meetings workspace"
sd_launch_configured_app "$SD_APPS_JSON" "calendar" || sd_log_warn "Calendar launch failed"
/usr/bin/osascript -e 'tell application "System Events" to set volume input volume 0' 2>/dev/null || true
sd_notify "Meetings" "Calendar opened; mic muted"
