# ROLLBACK

## Stream Deck configuration

```zsh
# Stop Stream Deck manually, then restore from backup:
BACKUP=~/Documents/GitHub/ipad-stream-deck-console/backups/stream-deck_YYYY-MM-DD_HH-MM-SS/StreamDeck
rm -rf ~/Library/Application\ Support/com.elgato.StreamDeck
cp -R "$BACKUP" ~/Library/Application\ Support/com.elgato.StreamDeck
open -a "Elgato Stream Deck"
```

Create a fresh backup before any profile change:

```zsh
zsh stream-deck/documentation/backup-stream-deck-config.zsh
```

## Login launch rollback

```zsh
zsh scripts/stream-deck/remove-streamdeck-login.zsh
```

## Lock file cleanup

```zsh
rm -f ~/.autogio/streamdeck/start-my-day.lock
```

## Scripts and config

Project files are in git. Revert with:

```zsh
cd ~/Documents/GitHub/ipad-stream-deck-console
git checkout -- .
```

User-created reports and logs are not removed by rollback.
