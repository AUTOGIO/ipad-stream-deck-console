#!/bin/zsh
# Stream Deck git helper: commit tracked/known changes only after confirmation.
# Never silently add -A or push. SD_SKIP_DIALOGS=1 refuses this action.
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

project_path="$(sd_get_active_project)"
sd_require_path "Active project" "$project_path" || exit 1

if ! /usr/bin/git -C "$project_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  sd_notify "Git" "Not a git repository: ${project_path}"
  exit 1
fi

if [[ "${SD_SKIP_DIALOGS:-}" == "1" ]]; then
  sd_notify "Git" "Commit+push refused in non-interactive mode"
  sd_log_warn "commit-push blocked under SD_SKIP_DIALOGS=1 for ${project_path}"
  exit 1
fi

status="$(/usr/bin/git -C "$project_path" status --porcelain)"
if [[ -z "$status" ]]; then
  sd_notify "Git" "Nothing to commit"
  exit 0
fi

# Block credential-like paths from ever being staged by this button.
secret_hits="$(print -r -- "$status" | /usr/bin/grep -E -i \
  '(^.. |\s)(\.env([.]|$)|.*credentials.*|.*secrets.*|id_rsa|id_ed25519|\.pem$|\.p12$|\.key$)' || true)"
if [[ -n "$secret_hits" ]]; then
  sd_notify "Git" "Blocked: secret-like files in working tree"
  sd_log_error "commit-push blocked secret-like paths:\n${secret_hits}"
  exit 1
fi

project_name="$(/usr/bin/basename "$project_path")"
branch="$(/usr/bin/git -C "$project_path" rev-parse --abbrev-ref HEAD 2>/dev/null || print -r -- "?")"
file_count="$(print -r -- "$status" | /usr/bin/wc -l | /usr/bin/tr -d ' ')"
preview="$(print -r -- "$status" | /usr/bin/head -n 12)"

confirm_msg="Project: ${project_name}
Branch: ${branch}
Changed paths: ${file_count}

${preview}

Stage all listed changes and commit?
(Does not push yet.)"
if ! sd_confirm_dialog "Git Commit" "$confirm_msg"; then
  sd_notify "Git" "Commit cancelled"
  exit 0
fi

message="$(/usr/bin/osascript -e 'text returned of (display dialog "Commit message:" default answer "chore: stream deck update" buttons {"Cancel", "Commit"} default button "Commit")' 2>/dev/null || true)"
[[ -z "$message" ]] && exit 0

# Stage only paths already known to git plus explicitly listed untracked from status —
# still uses add -u for tracked, then add -- each porcelain path after user confirmed the list.
/usr/bin/git -C "$project_path" add -u
print -r -- "$status" | while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  path="${line[4,-1]}"
  path="${path#\"}"
  path="${path%\"}"
  # Skip rename "old -> new" complexity; user already confirmed porcelain list.
  if [[ "$path" == *" -> "* ]]; then
    path="${path##* -> }"
  fi
  [[ -z "$path" ]] && continue
  /usr/bin/git -C "$project_path" add -- "$path" 2>/dev/null || true
done

if /usr/bin/git -C "$project_path" diff --cached --quiet; then
  sd_notify "Git" "Nothing staged after confirmation"
  exit 1
fi

/usr/bin/git -C "$project_path" commit -m "$message"
sd_log_info "Git commit complete for ${project_path}"

push_msg="Push ${project_name} (${branch}) to remote now?"
if sd_confirm_dialog "Git Push" "$push_msg"; then
  /usr/bin/git -C "$project_path" push
  sd_notify "Git" "Committed and pushed"
  sd_log_info "Git push complete for ${project_path}"
else
  sd_notify "Git" "Committed locally (push skipped)"
  sd_log_info "Git push skipped for ${project_path}"
fi
