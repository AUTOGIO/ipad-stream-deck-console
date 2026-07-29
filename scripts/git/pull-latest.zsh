#!/bin/zsh
# Stream Deck git helper: pull with rebase only after confirming project + branch.
# Autostash is opt-in via the confirmation dialog. SD_SKIP_DIALOGS=1 refuses this action.
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

project_path="$(sd_get_active_project)"
sd_require_path "Active project" "$project_path" || exit 1

if ! /usr/bin/git -C "$project_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  sd_notify "Git" "Not a git repository"
  exit 1
fi

if [[ "${SD_SKIP_DIALOGS:-}" == "1" ]]; then
  sd_notify "Git" "Pull refused in non-interactive mode"
  sd_log_warn "pull-latest blocked under SD_SKIP_DIALOGS=1 for ${project_path}"
  exit 1
fi

project_name="$(/usr/bin/basename "$project_path")"
branch="$(/usr/bin/git -C "$project_path" rev-parse --abbrev-ref HEAD 2>/dev/null || print -r -- "?")"
dirty="$(/usr/bin/git -C "$project_path" status --porcelain)"

confirm_msg="Pull with rebase into:
  ${project_name}
  branch ${branch}
  path ${project_path}"
if [[ -n "$dirty" ]]; then
  confirm_msg="${confirm_msg}

Working tree is dirty. Continue without autostash?
(Cancel and stash manually if unsure.)"
fi

if ! sd_confirm_dialog "Git Pull" "$confirm_msg"; then
  sd_notify "Git" "Pull cancelled"
  exit 0
fi

/usr/bin/git -C "$project_path" pull --rebase
sd_notify "Git" "Pull complete"
sd_log_info "Git pull complete for ${project_path}"
