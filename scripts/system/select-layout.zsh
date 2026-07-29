#!/bin/zsh
# scripts/system/select-layout.zsh — select layout JSON file for current displays
# Prints absolute path to layout JSON on stdout.

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

preferred="$(sd_config_get "layouts.preferred" 2>/dev/null || print -r -- "auto")"
mode="${1:-}"

if [[ -z "$mode" ]]; then
  if [[ "$preferred" == "auto" ]]; then
    mode="$(zsh "${SD_ROOT}/scripts/system/detect-displays.zsh" | /usr/bin/head -1)"
  else
    mode="$preferred"
  fi
fi

case "$mode" in
  dual_display) layout_file="${SD_ROOT}/layouts/dual-display.json" ;;
  single_external) layout_file="${SD_ROOT}/layouts/single-external.json" ;;
  single_builtin) layout_file="${SD_ROOT}/layouts/single-builtin.json" ;;
  safe_layout|*) layout_file="${SD_ROOT}/layouts/safe-layout.json" ;;
esac

if [[ ! -f "$layout_file" ]]; then
  sd_log_error "Layout file missing: ${layout_file}"
  layout_file="${SD_ROOT}/layouts/safe-layout.json"
fi

sd_log_info "Selected layout mode: ${mode} -> ${layout_file}"
print -r -- "$layout_file"
