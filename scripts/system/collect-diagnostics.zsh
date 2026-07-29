#!/bin/zsh
# scripts/system/collect-diagnostics.zsh — non-destructive diagnostics archive

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

reports_dir="$(sd_load_path "$SD_PATHS_JSON" "reports_dir")"
logs_dir="$(sd_load_path "$SD_PATHS_JSON" "logs_dir")"
/bin/mkdir -p "$reports_dir"

timestamp="$(/bin/date '+%Y-%m-%d_%H-%M-%S')"
staging_dir="$(/usr/bin/mktemp -d "${reports_dir}/.diagnostics_staging_${timestamp}.XXXXXX")"
archive_file="${reports_dir}/diagnostics_${timestamp}.zip"

cleanup() {
  /bin/rm -rf "$staging_dir"
}
trap cleanup EXIT

/bin/mkdir -p "${staging_dir}/system" "${staging_dir}/config" "${staging_dir}/logs" "${staging_dir}/stream-deck"

# System metadata
{
  print -r -- "Diagnostics collected: $(/bin/date '+%Y-%m-%d %H:%M:%S %Z')"
  /usr/bin/sw_vers 2>/dev/null
  /usr/bin/uptime 2>/dev/null
} >"${staging_dir}/system/overview.txt"

/bin/df -h / >"${staging_dir}/system/disk.txt" 2>/dev/null || true
/usr/bin/memory_pressure >"${staging_dir}/system/memory.txt" 2>/dev/null || /usr/bin/vm_stat >"${staging_dir}/system/memory.txt" 2>/dev/null || true
/sbin/ifconfig >"${staging_dir}/system/network.txt" 2>/dev/null || true
/usr/bin/ps aux >"${staging_dir}/system/processes.txt" 2>/dev/null || true

# Process status for key apps
{
  for svc in "Stream Deck" "ActivityWatch" "Hammerspoon" "Cursor" "Ghostty"; do
    if sd_process_running "$svc"; then
      print -r -- "${svc}: RUNNING"
    else
      print -r -- "${svc}: NOT RUNNING"
    fi
  done
} >"${staging_dir}/system/app_status.txt"

# Project config (no secrets)
/bin/cp "${SD_ROOT}/config/apps.json" "${staging_dir}/config/"
/bin/cp "${SD_ROOT}/config/paths.json" "${staging_dir}/config/"
/bin/cp "${SD_ROOT}/STATUS.md" "${staging_dir}/config/"

# Recent script logs
if [[ -f "${logs_dir}/ipad-stream-deck-console.log" ]]; then
  /usr/bin/tail -200 "${logs_dir}/ipad-stream-deck-console.log" >"${staging_dir}/logs/ipad-stream-deck-console.log"
fi

# Stream Deck metadata (not full config — may contain device info)
sd_config_dir="${HOME}/Library/Application Support/com.elgato.StreamDeck"
if [[ -d "$sd_config_dir" ]]; then
  {
    print -r -- "Stream Deck config directory exists"
    /bin/ls -la "$sd_config_dir" 2>/dev/null
    print -r -- ""
    if [[ -d "${sd_config_dir}/Profiles" ]]; then
      print -r -- "Profiles:"
      /bin/ls -la "${sd_config_dir}/Profiles" 2>/dev/null
    fi
    if [[ -d "${sd_config_dir}/Plugins" ]]; then
      print -r -- "Plugins:"
      /bin/ls -la "${sd_config_dir}/Plugins" 2>/dev/null
    fi
  } >"${staging_dir}/stream-deck/metadata.txt" 2>/dev/null || true
else
  print -r -- "Stream Deck not installed or config directory missing" >"${staging_dir}/stream-deck/metadata.txt"
fi

# Build inclusion manifest for user confirmation
manifest_file="${staging_dir}/INCLUSION_MANIFEST.txt"
{
  print -r -- "The following items will be included in the diagnostics archive:"
  print -r -- ""
  /usr/bin/find "$staging_dir" -type f ! -name 'INCLUSION_MANIFEST.txt' | /usr/bin/sort | while read -r f; do
    size="$(/usr/bin/stat -f%z "$f" 2>/dev/null || echo 0)"
    rel="${f#${staging_dir}/}"
    print -r -- "  ${rel} (${size} bytes)"
  done
  print -r -- ""
  print -r -- "Excluded by design:"
  print -r -- "  - Passwords, tokens, API keys, cookies"
  print -r -- "  - Browser history, email, personal documents"
  print -r -- "  - Full Stream Deck profile binaries"
} >"$manifest_file"

/usr/bin/open "$manifest_file"

if ! sd_confirm_dialog "Collect Diagnostics" "Review INCLUSION_MANIFEST.txt.\n\nCreate diagnostics archive?"; then
  sd_log_info "Diagnostics collection cancelled by user"
  sd_show_dialog "Diagnostics Cancelled" "No archive was created."
  exit 0
fi

(
  cd "$staging_dir"
  /usr/bin/zip -r "$archive_file" . >/dev/null
)

sd_log_info "Diagnostics archive created: ${archive_file}"
/usr/bin/open -R "$archive_file"
sd_show_dialog "Diagnostics Complete" "Archive saved to:\n${archive_file}"
