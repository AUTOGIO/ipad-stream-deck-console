#!/bin/zsh
# Open a URL in Chrome when installed, otherwise default browser.
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

url="${1:-}"
[[ -n "$url" ]] || { sd_log_error "Usage: open-url.zsh <url>"; exit 1; }

if [[ -d "/Applications/Google Chrome.app" ]]; then
  /usr/bin/open -a "Google Chrome" "$url" >/dev/null 2>&1 || /usr/bin/open "$url"
else
  /usr/bin/open "$url"
fi

sd_log_info "Opened URL: ${url}"
sd_notify "Browser" "Opened link"
