#!/bin/zsh
# stream-deck/documentation/backup-stream-deck-config.zsh
# Run after Elgato Stream Deck is installed.

set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"

PROJECT_ROOT="/Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console"
TIMESTAMP="$(/bin/date '+%Y-%m-%d_%H-%M-%S')"
BACKUP_DIR="${PROJECT_ROOT}/backups/stream-deck_${TIMESTAMP}"
SD_CONFIG="${HOME}/Library/Application Support/com.elgato.StreamDeck"

/bin/mkdir -p "$BACKUP_DIR"

if [[ ! -d "$SD_CONFIG" ]]; then
  print -r -- "No Stream Deck config found at:"
  print -r -- "  ${SD_CONFIG}"
  print -r -- ""
  print -r -- "Install Elgato Stream Deck first:"
  print -r -- "  https://www.elgato.com/downloads"
  exit 1
fi

/bin/cp -R "$SD_CONFIG" "${BACKUP_DIR}/StreamDeck"
print -r -- "Backup created:"
print -r -- "  ${BACKUP_DIR}/StreamDeck"
/usr/bin/find "${BACKUP_DIR}/StreamDeck" -type f | /usr/bin/wc -l | /usr/bin/awk '{print "  Files:", $1}'
