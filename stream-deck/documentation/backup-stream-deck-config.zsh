#!/bin/zsh
# stream-deck/documentation/backup-stream-deck-config.zsh
# Slim backup of Elgato Profiles/Preferences (excludes bundled NodeJS runtime).
# Run after Elgato Stream Deck is installed.

set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
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

# Prefer ProfilesV2/V3 + Preferences; skip NodeJS and other bulky plugin runtimes.
copy_if_exists() {
  local src="$1"
  local dest_name="$2"
  if [[ -e "$src" ]]; then
    /bin/mkdir -p "${BACKUP_DIR}/StreamDeck"
    /bin/cp -R "$src" "${BACKUP_DIR}/StreamDeck/${dest_name}"
    print -r -- "  + ${dest_name}"
  fi
}

print -r -- "Backing up Stream Deck (slim — no NodeJS):"
copy_if_exists "${SD_CONFIG}/ProfilesV2" "ProfilesV2"
copy_if_exists "${SD_CONFIG}/ProfilesV3" "ProfilesV3"
copy_if_exists "${SD_CONFIG}/Profiles" "Profiles"
copy_if_exists "${SD_CONFIG}/Preferences" "Preferences"
# Keep a shallow listing of the rest for inventory without copying binaries.
{
  print -r -- "Source: ${SD_CONFIG}"
  print -r -- "Captured: $(/bin/date '+%Y-%m-%d %H:%M:%S %Z')"
  /bin/ls -la "$SD_CONFIG" 2>/dev/null || true
} >"${BACKUP_DIR}/StreamDeck/SOURCE_LISTING.txt"

if [[ ! -d "${BACKUP_DIR}/StreamDeck" ]]; then
  print -r -- "ERROR: nothing was backed up from ${SD_CONFIG}" >&2
  exit 1
fi

print -r -- "Backup created:"
print -r -- "  ${BACKUP_DIR}/StreamDeck"
/usr/bin/du -sh "${BACKUP_DIR}" | /usr/bin/awk '{print "  Size:", $1}'
/usr/bin/find "${BACKUP_DIR}/StreamDeck" -type f | /usr/bin/wc -l | /usr/bin/awk '{print "  Files:", $1}'
