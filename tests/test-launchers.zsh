#!/bin/zsh
# tests/test-launchers.zsh — smoke-test launch scripts

set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"
export SD_SKIP_DIALOGS=1

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "${ROOT}/scripts/lib/common.zsh"
sd_init_logging "$ROOT"

scripts=(
  "scripts/launch/open-cursor.zsh"
  "scripts/launch/open-lm-studio.zsh"
  "scripts/launch/open-activitywatch.zsh"
  "scripts/launch/open-finder-home.zsh"
  "scripts/launch/open-github-projects.zsh"
  "scripts/launch/open-chatgpt.zsh"
  "scripts/launch/open-claude-code.zsh"
  "scripts/launch/open-obsidian-ai.zsh"
  "scripts/launch/open-terminal.zsh"
  "scripts/launch/open-activity-monitor.zsh"
)

passed=0
failed=0

for rel in "${scripts[@]}"; do
  script="${ROOT}/${rel}"
  if [[ ! -x "$script" ]]; then
    /bin/chmod +x "$script"
  fi
  if zsh "$script" >/dev/null 2>&1; then
    print -r -- "PASS  ${rel}"
    passed=$((passed + 1))
  else
    print -r -- "FAIL  ${rel}" >&2
    failed=$((failed + 1))
  fi
done

print -r -- "---"
print -r -- "Passed: ${passed}"
print -r -- "Failed: ${failed}"

(( failed == 0 )) || exit 1
