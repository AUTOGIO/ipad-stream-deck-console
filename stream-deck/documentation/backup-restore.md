# Stream Deck Backup and Restore

## Before Changing Stream Deck Configuration

Always back up before creating or importing profiles.

### Backup Location

Store backups in the project directory (not in Git):

```
/Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console/backups/stream-deck_YYYY-MM-DD_HH-MM-SS/
```

### Backup Command

Run only after Stream Deck is installed:

```zsh
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
BACKUP_DIR="$HOME/Documents/GitHub/ipad-stream-deck-console/backups/stream-deck_${TIMESTAMP}"
SD_CONFIG="$HOME/Library/Application Support/com.elgato.StreamDeck"

mkdir -p "$BACKUP_DIR"
if [[ -d "$SD_CONFIG" ]]; then
  cp -R "$SD_CONFIG" "$BACKUP_DIR/StreamDeck"
  echo "Backed up to: $BACKUP_DIR"
else
  echo "No Stream Deck config found at: $SD_CONFIG"
fi
```

### Verify Backup

```zsh
ls -la "$BACKUP_DIR/StreamDeck"
```

## Restore Procedure

1. Quit Stream Deck application
2. Rename current config as safety copy:

   ```zsh
   mv "$HOME/Library/Application Support/com.elgato.StreamDeck" \
      "$HOME/Library/Application Support/com.elgato.StreamDeck.disabled"
   ```

3. Restore from backup:

   ```zsh
   cp -R "$BACKUP_DIR/StreamDeck" \
         "$HOME/Library/Application Support/com.elgato.StreamDeck"
   ```

4. Relaunch Stream Deck
5. Verify profile and buttons

## Export Profile from Stream Deck App

1. Open Stream Deck
2. Right-click profile → **Export**
3. Save to `stream-deck/profiles/` in this project
4. Do not commit large binary profiles to Git (see `.gitignore`)

## Current Status

No Stream Deck configuration exists on this Mac yet. First backup will occur at GATE 5 when Stream Deck is installed.
