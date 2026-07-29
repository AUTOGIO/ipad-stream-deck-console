#!/bin/zsh
# scripts/spencer/run-layout-shortcut.zsh — restore Spencer layout (Start My Day pattern)
#
# Usage: run-layout-shortcut.zsh <LAYOUT_NAME>
# Runs the same shell body as the Start My Day Shortcut via restore-layout.zsh.
# Optionally uses a working Apple Shortcut when present (never trusts empty Hello World stubs).

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

layout_name="${1:-}"
if [[ -z "$layout_name" ]]; then
  sd_log_error "Usage: run-layout-shortcut.zsh <LAYOUT_NAME>"
  exit 1
fi

# Prefer known-good Shortcut only for Start My Day (matches your working Shortcut).
if [[ "$layout_name" == "START_MY_DAY" ]]; then
  if /usr/bin/shortcuts list 2>/dev/null | /usr/bin/grep -Fxq -- "Start My Day"; then
    sd_log_info "Running Apple Shortcut: Start My Day"
    if /usr/bin/shortcuts run "Start My Day"; then
      sd_notify "Spencer" "Ran shortcut: Start My Day"
      exit 0
    fi
    sd_log_warn "Start My Day Shortcut failed; falling back to CLI"
  fi
fi

# Exact Start My Day pattern (open → wait → restore --launch-apps=true)
layout_zsh="${SD_ROOT}/shortcuts/spencer/${layout_name}.zsh"
if [[ -x "$layout_zsh" ]]; then
  sd_log_info "Running Start My Day–style script: ${layout_zsh}"
  if /bin/zsh "$layout_zsh"; then
    sd_notify "Spencer" "Restored ${layout_name}"
    exit 0
  fi
  sd_log_warn "Layout .zsh failed; trying restore-layout.zsh"
fi

zsh "${SD_ROOT}/scripts/spencer/restore-layout.zsh" "$layout_name"
