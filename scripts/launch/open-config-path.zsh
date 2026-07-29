#!/bin/zsh
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

path_key="${1:-}"
[[ -n "$path_key" ]] || { sd_log_error "Usage: open-config-path.zsh <path_key>"; exit 1; }

target="$(sd_config_get "paths.${path_key}" 2>/dev/null || sd_load_path "$SD_PATHS_JSON" "$path_key" 2>/dev/null || true)"
sd_require_path "$path_key" "$target" || exit 1
sd_open_path "$target" "$path_key"
