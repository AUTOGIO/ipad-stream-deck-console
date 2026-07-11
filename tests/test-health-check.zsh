#!/bin/zsh
# tests/test-health-check.zsh — verify health check produces a report

set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"
export SD_SKIP_DIALOGS=1

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
script="${ROOT}/scripts/system/health-check.zsh"

/bin/chmod +x "$script"
zsh "$script"

reports=( "${ROOT}"/reports/health-check_*.txt(N) )
if (( ${#reports[@]} == 0 )); then
  print -r -- "FAIL  No health check report created" >&2
  exit 1
fi
latest="${reports[1]}"

for marker in "macOS" "Disk Usage" "Service Status" "Network Reachability"; do
  if ! /usr/bin/grep -q "$marker" "$latest"; then
    print -r -- "FAIL  Missing section: ${marker}" >&2
    exit 1
  fi
done

print -r -- "PASS  Health check report: ${latest}"
print -r -- "PASS  All required sections present"
