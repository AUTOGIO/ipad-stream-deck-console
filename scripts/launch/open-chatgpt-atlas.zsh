#!/bin/zsh
# scripts/launch/open-chatgpt-atlas.zsh — open ChatGPT Atlas directly

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

sd_launch_configured_app "$SD_APPS_JSON" "chatgpt_atlas"
