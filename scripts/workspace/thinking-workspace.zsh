#!/bin/zsh
# scripts/workspace/thinking-workspace.zsh — Thinking via Apple Shortcut / Spencer

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

zsh "${SD_ROOT}/scripts/spencer/run-layout-shortcut.zsh" "THINKING_WORKSPACE"
