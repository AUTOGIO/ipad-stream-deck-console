#!/bin/zsh
# Invoke Hammerspoon AI prompt via operations URL.
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

prompt="${1:-}"
if [[ -z "$prompt" ]]; then
  sd_log_error "Usage: ai-prompt.zsh <prompt_name>"
  exit 1
fi

sd_invoke_hammerspoon "ai_prompt" "prompt=${prompt}"
