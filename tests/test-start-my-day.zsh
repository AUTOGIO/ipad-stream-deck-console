#!/bin/zsh
# tests/test-start-my-day.zsh — smoke test Start My Day workflow

set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"
export SD_SKIP_DIALOGS=1

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
script="${ROOT}/scripts/workspace/start-my-day.zsh"

/bin/chmod +x "$script"
zsh "$script"

if [[ ! -f "${HOME}/.autogio/streamdeck/start-my-day.lock" ]]; then
  print -r -- "PASS  Lock released after Start My Day"
else
  print -r -- "WARN  Lock file still present (may be stale)"
fi

print -r -- "PASS  Start My Day completed without error"
