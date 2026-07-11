#!/bin/zsh
# scripts/system/health-check.zsh — read-only system health report

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

reports_dir="$(sd_load_path "$SD_PATHS_JSON" "reports_dir")"
/bin/mkdir -p "$reports_dir"

timestamp="$(/bin/date '+%Y-%m-%d_%H-%M-%S')"
report_file="${reports_dir}/health-check_${timestamp}.txt"

{
  print -r -- "iPad Stream Deck Console — Health Check"
  print -r -- "Generated: $(/bin/date '+%Y-%m-%d %H:%M:%S %Z')"
  print -r -- "Host: $(/usr/sbin/scutil --get ComputerName 2>/dev/null || /bin/hostname)"
  print -r -- "========================================"
  print -r -- ""

  print -r -- "## macOS"
  /usr/bin/sw_vers 2>/dev/null || print -r -- "sw_vers unavailable"
  print -r -- ""
  print -r -- "Uptime:"
  /usr/bin/uptime 2>/dev/null || true
  print -r -- ""

  print -r -- "## Disk Usage (/)"
  /bin/df -h / 2>/dev/null || true
  print -r -- ""

  print -r -- "## Memory Pressure"
  /usr/bin/memory_pressure 2>/dev/null | /usr/bin/head -12 || /usr/bin/vm_stat 2>/dev/null | /usr/bin/head -8 || true
  print -r -- ""

  print -r -- "## Top CPU Processes"
  /usr/bin/ps -Ao pid,pcpu,comm -r 2>/dev/null | /usr/bin/head -8 || true
  print -r -- ""

  print -r -- "## Top Memory Processes"
  /usr/bin/ps -Ao pid,pmem,comm -m 2>/dev/null | /usr/bin/head -8 || true
  print -r -- ""

  print -r -- "## Failed User LaunchAgents"
  if /bin/ls "$HOME/Library/LaunchAgents"/*.plist >/dev/null 2>&1; then
    for plist in "$HOME/Library/LaunchAgents"/*.plist; do
      label="$(/usr/bin/defaults read "${plist%.plist}" Label 2>/dev/null || /usr/bin/basename "$plist" .plist)"
      state="$(/bin/launchctl list 2>/dev/null | /usr/bin/awk -v lbl="$label" '$3 == lbl {print $1 "|" $2}')"
      if [[ -n "$state" ]]; then
        pid="${state%%|*}"
        last_status="${state##*|}"
        if [[ "$last_status" != "0" && "$last_status" != "-" ]]; then
          print -r -- "FAILED  ${label} (status: ${last_status})"
        elif [[ "$pid" == "-" ]]; then
          print -r -- "STOPPED ${label}"
        else
          print -r -- "OK      ${label} (pid: ${pid})"
        fi
      fi
    done
  else
    print -r -- "No user LaunchAgents found"
  fi
  print -r -- ""

  print -r -- "## Service Status"
  for svc in "Stream Deck:Stream Deck" "ActivityWatch:ActivityWatch" "LM Studio:LM Studio" "Ollama:ollama" "Hammerspoon:Hammerspoon"; do
    label="${svc%%:*}"
    pattern="${svc##*:}"
    if sd_process_running "$pattern"; then
      print -r -- "${label}: RUNNING"
    else
      print -r -- "${label}: NOT RUNNING"
    fi
  done
  print -r -- ""

  print -r -- "## Network Reachability"
  if /sbin/ping -c 1 -t 2 1.1.1.1 >/dev/null 2>&1; then
    print -r -- "Internet: REACHABLE (1.1.1.1)"
  else
    print -r -- "Internet: UNREACHABLE"
  fi
  if /sbin/ping -c 1 -t 2 192.168.0.1 >/dev/null 2>&1; then
    print -r -- "Gateway:  REACHABLE (192.168.0.1)"
  else
    print -r -- "Gateway:  UNREACHABLE"
  fi
  print -r -- ""
  print -r -- "Local IP:"
  /usr/sbin/ipconfig getifaddr en0 2>/dev/null || /usr/sbin/ipconfig getifaddr en5 2>/dev/null || print -r -- "unknown"
  print -r -- ""

  print -r -- "## End of Report"
} >"$report_file"

sd_log_info "Health check report written: ${report_file}"
/usr/bin/open -R "$report_file"
sd_show_dialog "Health Check Complete" "Report saved to:\n${report_file}"
