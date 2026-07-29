#!/bin/zsh
# scripts/workspace/restore-spencer-layout.zsh — restore via Apple Shortcut / Spencer CLI

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

if [[ $# -lt 1 ]]; then
  sd_log_error "Missing layout name argument"
  sd_notify "Spencer Layout Error" "Please specify a layout name."
  exit 1
fi

zsh "${SD_ROOT}/scripts/spencer/run-layout-shortcut.zsh" "$1"
