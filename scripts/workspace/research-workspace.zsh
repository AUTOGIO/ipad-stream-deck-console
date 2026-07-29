#!/bin/zsh
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

sd_log_info "Activating Research workspace"
sd_launch_configured_app "$SD_APPS_JSON" "chatgpt_atlas" || sd_log_warn "ChatGPT Atlas launch failed"
sd_launch_configured_app "$SD_APPS_JSON" "notes" || sd_log_warn "Notes launch failed"
sd_apply_hammerspoon_layout "writing"
sd_notify "Research" "Research workspace ready"
