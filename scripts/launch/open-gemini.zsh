#!/bin/zsh
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

/usr/bin/open "https://gemini.google.com"
sd_log_info "Opened Gemini"
sd_notify "Browser" "Gemini opened"
