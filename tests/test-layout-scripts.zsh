#!/bin/zsh
# tests/test-layout-scripts.zsh — verify display detection and layout selection

set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

mode="$(zsh "${ROOT}/scripts/system/detect-displays.zsh" | /usr/bin/head -1)"
case "$mode" in
  dual_display|single_external|single_builtin|safe_layout)
    print -r -- "PASS  detect-displays -> ${mode}"
    ;;
  *)
    print -r -- "FAIL  unexpected detect mode: ${mode}" >&2
    exit 1
    ;;
esac

layout_file="$(zsh "${ROOT}/scripts/system/select-layout.zsh")"
if [[ -f "$layout_file" ]]; then
  print -r -- "PASS  select-layout -> ${layout_file}"
else
  print -r -- "FAIL  layout file missing: ${layout_file}" >&2
  exit 1
fi

SD_SKIP_DIALOGS=1 zsh "${ROOT}/scripts/workspace/reset-daily-layout.zsh"
print -r -- "PASS  reset-daily-layout completed"
