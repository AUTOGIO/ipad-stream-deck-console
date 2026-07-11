#!/bin/zsh
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"
projects_root="$(sd_load_path "$SD_PATHS_JSON" "projects_root")"
sd_open_path "$projects_root" "GitHub projects"
