# INSTALLATION

## 1. Prerequisites

- macOS Apple Silicon
- Elgato Stream Deck 7.5+
- Hammerspoon (for window layouts)
- zsh

## 2. Project location

```zsh
cd ~/Documents/GitHub/ipad-stream-deck-console
chmod +x scripts/**/*.zsh tests/*.zsh
```

## 3. Validate configuration

```zsh
# If config.json is missing after clone:
cp config/config.example.json config/config.json
# Edit YOUR_USERNAME / project paths, then:
zsh tests/validate-config.zsh
```

## 4. Runtime directories

Created automatically on first run:

- `~/Library/Application Support/AUTOGIO/streamdeck/`
- `~/Library/Logs/AUTOGIO/StreamDeck/`

## 5. Stream Deck login launch

```zsh
zsh scripts/stream-deck/configure-streamdeck-login.zsh
```

Rollback:

```zsh
zsh scripts/stream-deck/remove-streamdeck-login.zsh
```

## 6. Build profiles

```zsh
# Backup first
zsh stream-deck/documentation/backup-stream-deck-config.zsh

# Build both profiles
python3 scripts/stream-deck/build-profile.py --profile all
```

Select **Operations Console** on physical Stream Deck and **iPad Work Console** on Stream Deck Mobile (primary). Legacy **iPad Console** is rollback-only.

Preferred mobile build:

```zsh
python3 scripts/stream-deck/build-profile.py --profile ipad-work
```

## 7. iPad pairing

See [ipad-pairing-checklist.md](ipad-pairing-checklist.md).

## 8. Test MVP

```zsh
export SD_SKIP_DIALOGS=1
zsh tests/test-launchers.zsh
zsh tests/test-health-check.zsh
zsh tests/test-layout-scripts.zsh
zsh tests/test-start-my-day.zsh
```
