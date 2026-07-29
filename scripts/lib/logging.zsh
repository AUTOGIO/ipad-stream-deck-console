#!/bin/zsh
# scripts/lib/logging.zsh — shared logging helpers

typeset -g SD_LOG_DIR=""
typeset -g SD_LOG_FILE=""

sd_init_logging() {
  local project_root="$1"
  local autogio_logs="${HOME}/Library/Logs/AUTOGIO/StreamDeck"
  if [[ -d "$autogio_logs" || -d "${HOME}/Library/Logs/AUTOGIO" ]]; then
    SD_LOG_DIR="$autogio_logs"
  else
    SD_LOG_DIR="${project_root}/logs"
  fi
  /bin/mkdir -p "$SD_LOG_DIR"
  SD_LOG_FILE="${SD_LOG_DIR}/ipad-stream-deck-console.log"
}

sd_timestamp() {
  /bin/date '+%Y-%m-%d %H:%M:%S'
}

sd_log_write() {
  local level="$1"
  local message="$2"
  local line="[$(sd_timestamp)] [${level}] ${message}"
  print -r -- "$line" >>"$SD_LOG_FILE"
  if [[ "$level" == "ERROR" ]]; then
    print -r -- "$line" >&2
  fi
}

sd_log_info() {
  sd_log_write "INFO" "$1"
}

sd_log_warn() {
  sd_log_write "WARN" "$1"
}

sd_log_error() {
  sd_log_write "ERROR" "$1"
}
