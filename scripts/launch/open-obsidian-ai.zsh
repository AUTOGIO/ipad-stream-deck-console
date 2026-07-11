#!/bin/zsh
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

vault_path="$(sd_load_path "$SD_PATHS_JSON" "obsidian_ai_vault")"
vault_name="$(sd_load_path "$SD_PATHS_JSON" "obsidian_ai_vault_name")"

sd_require_path "Obsidian vault" "$vault_path" || exit 1
sd_launch_configured_app "$SD_APPS_JSON" "obsidian" || exit 1

encoded_name="$(printf '%s' "$vault_name" | /usr/bin/python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))')"
/usr/bin/open "obsidian://open?vault=${encoded_name}"
sd_log_info "Opened Obsidian vault: ${vault_name}"
