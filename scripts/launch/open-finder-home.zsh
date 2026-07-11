#!/bin/zsh
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"
home_path="$(sd_load_path "$SD_PATHS_JSON" "home")"
sd_open_path "$home_path" "Home folder"
