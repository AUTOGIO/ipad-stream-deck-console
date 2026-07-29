#!/bin/zsh
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

action="${1:-}"
[[ -n "$action" ]] || { sd_log_error "Usage: invoke-hammerspoon.zsh <action>"; exit 1; }
shift || true
sd_invoke_hammerspoon "$action" "$@"
