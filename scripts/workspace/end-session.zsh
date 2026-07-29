#!/bin/zsh
# End work session: git snapshot, review prompts, Markdown log, then close the
# applications launched by START MY DAY.
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

stamp="$(/bin/date '+%Y-%m-%dT%H:%M:%S%z')"

project_source="saved pointer"
project_path="$(sd_detect_cursor_project 2>/dev/null || true)"
if [[ -n "$project_path" ]]; then
  project_source="Cursor workspace"
  sd_set_active_project "$project_path"
else
  project_path="$(sd_get_active_project 2>/dev/null || true)"
fi
project_name="none"
[[ -n "$project_path" ]] && project_name="$(/usr/bin/basename "$project_path")"
sd_log_info "End Session project source=${project_source} path=${project_path:-none}"

git_summary="Git: unavailable"
plain_project_status="Project status could not be checked."
if [[ -n "$project_path" && -d "$project_path" ]] && /usr/bin/git -C "$project_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch="$(git -C "$project_path" rev-parse --abbrev-ref HEAD 2>/dev/null || print -r -- "?")"
  modified="$(git -C "$project_path" status --porcelain 2>/dev/null | /usr/bin/grep -cE '^( M|M |MM|A |D |R )' || true)"
  untracked="$(git -C "$project_path" status --porcelain 2>/dev/null | /usr/bin/grep -cE '^\?\?' || true)"
  ahead="$(git -C "$project_path" rev-list --count '@{u}..HEAD' 2>/dev/null || print -r -- "unknown")"
  behind="$(git -C "$project_path" rev-list --count 'HEAD..@{u}' 2>/dev/null || print -r -- "unknown")"
  git_summary="Project: ${project_name} | Branch: ${branch} | Modified: ${modified} | Untracked: ${untracked} | Ahead: ${ahead} | Behind: ${behind}"

  modified_word="file"
  untracked_word="file"
  ahead_word="change"
  behind_word="change"
  (( modified != 1 )) && modified_word="files"
  (( untracked != 1 )) && untracked_word="files"
  [[ "$ahead" != "1" ]] && ahead_word="changes"
  [[ "$behind" != "1" ]] && behind_word="changes"
  if (( modified == 0 && untracked == 0 )); then
    plain_file_status="No unfinished project files were detected."
  elif (( modified > 0 && untracked > 0 )); then
    plain_file_status="${modified} edited ${modified_word} and ${untracked} new ${untracked_word} still need to be recorded in the project history."
  elif (( modified > 0 )); then
    plain_file_status="${modified} edited ${modified_word} still need to be recorded in the project history."
  else
    plain_file_status="${untracked} new ${untracked_word} still need to be recorded in the project history."
  fi

  if [[ "$ahead" == <-> && "$behind" == <-> ]]; then
    if (( ahead == 0 && behind == 0 )); then
      plain_sync_status="The project is up to date with its shared copy."
    elif (( ahead > 0 && behind == 0 )); then
      plain_sync_status="${ahead} saved ${ahead_word} have not yet been shared."
    elif (( ahead == 0 && behind > 0 )); then
      plain_sync_status="${behind} shared ${behind_word} have not yet been downloaded."
    else
      plain_sync_status="${ahead} saved ${ahead_word} need sharing and ${behind} shared ${behind_word} need downloading."
    fi
  else
    plain_sync_status="The shared-copy status could not be checked."
  fi
  plain_project_status="${plain_file_status} ${plain_sync_status}"
fi

completed="(skipped)"
remaining="(skipped)"
next_action="(skipped)"
if [[ "${SD_SKIP_DIALOGS:-}" != "1" ]]; then
  completed="$(/usr/bin/osascript -e 'text returned of (display dialog "What was completed?" with title "End Session" default answer "" buttons {"OK"} default button "OK")' 2>/dev/null || print -r -- "")"
  remaining="$(/usr/bin/osascript -e 'text returned of (display dialog "What remains?" with title "End Session" default answer "" buttons {"OK"} default button "OK")' 2>/dev/null || print -r -- "")"
  next_action="$(/usr/bin/osascript -e 'text returned of (display dialog "What is the next action?" with title "End Session" default answer "" buttons {"OK"} default button "OK")' 2>/dev/null || print -r -- "")"
fi

human_stamp="$(/bin/date '+%A, %B %-d, %Y at %-I:%M %p')"
[[ -z "$completed" || "$completed" == "(skipped)" ]] && completed="No written summary was entered."
[[ -z "$remaining" || "$remaining" == "(skipped)" ]] && remaining="No remaining work was recorded."
[[ -z "$next_action" || "$next_action" == "(skipped)" ]] && next_action="No next action was recorded."

sd_append_session_log ""
sd_append_session_log "## ${human_stamp}"
sd_append_session_log ""
sd_append_session_log "**Project:** ${project_name}"
sd_append_session_log ""
sd_append_session_log "**Project status:** ${plain_project_status}"
sd_append_session_log ""
sd_append_session_log "**Completed:** ${completed}"
sd_append_session_log ""
sd_append_session_log "**Still to do:** ${remaining}"
sd_append_session_log ""
sd_append_session_log "**Next action:** ${next_action}"

if [[ "$(sd_config_get "session.quit_apps" 2>/dev/null || print -r -- "false")" == "true" ]]; then
  while IFS= read -r app_name; do
    [[ -n "$app_name" ]] || continue
    sd_quit_app_by_name "$app_name" || true
  done < <(sd_json_list "$SD_CONFIG_JSON" "session.quit_work_apps")
fi

# Project-owned generated snapshot. The central daily log remains a personal
# cross-project journal; this report belongs beside the project it describes.
report_file=""
if [[ -n "$project_path" && -d "$project_path" ]] && /usr/bin/git -C "$project_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  reports_dir="${project_path}/reports/session"
  /bin/mkdir -p "$reports_dir"

  # Keep generated snapshots out of the project's working tree without
  # changing its tracked .gitignore policy.
  git_dir="$(/usr/bin/git -C "$project_path" rev-parse --git-dir)"
  [[ "$git_dir" != /* ]] && git_dir="${project_path}/${git_dir}"
  exclude_file="${git_dir}/info/exclude"
  /bin/mkdir -p "$(/usr/bin/dirname "$exclude_file")"
  /usr/bin/touch "$exclude_file"
  if ! /usr/bin/grep -Fqx '/reports/session/session-end-*.md' "$exclude_file"; then
    print -r -- "# AUTOGIO generated session snapshots" >>"$exclude_file"
    print -r -- "/reports/session/session-end-*.md" >>"$exclude_file"
  fi

  report_file="${reports_dir}/session-end-$(/bin/date '+%Y-%m-%d_%H-%M-%S').md"
  {
    print -r -- "# Session End"
    print -r -- ""
    print -r -- "- Timestamp: ${stamp}"
    print -r -- "- ${git_summary}"
    print -r -- "- Completed: ${completed}"
    print -r -- "- Remaining: ${remaining}"
    print -r -- "- Next action: ${next_action}"
  } >"$report_file"
else
  sd_log_warn "No Git project available; skipped project session snapshot"
fi

if [[ -n "$report_file" && -f "$report_file" ]]; then
  completion_title="End Session Complete"
  completion_message="Session saved for ${project_name}. Review Apple Notes: AUTOGIO / END SESSION."
  completion_dialog="Session saved for ${project_name}.\n\nYour technical project record is saved. Review Apple Notes: AUTOGIO / END SESSION.\n\nStart My Day apps were closed."
else
  completion_title="End Session Needs Attention"
  completion_message="The daily journal was saved, but no project record could be created. Review Apple Notes or contact Codex."
  completion_dialog="The daily journal was saved, but no project record could be created.\n\nReview Apple Notes or contact Codex."
fi

sd_notify "$completion_title" "$completion_message"
sd_show_dialog "$completion_title" "$completion_dialog"
sd_log_info "End session project=${project_name} report=${report_file:-skipped}"
