# iPad Stream Deck Console

Turn an iPad running **Stream Deck Mobile** (and/or a physical Stream Deck) into a Mac control surface.

## Objective

The iPad/deck is the control surface. The Mac executes workflows through thin Open actions that run zsh scripts in this repository.

## Architecture

```
iPad / Physical Stream Deck
        ↓
Elgato Stream Deck (macOS)
        ↓
Thin button action (Open .command / hammerspoon:// / Shortcut)
        ↓
Script in ipad-stream-deck-console
        ↓
Actual workflow (launch app, layout, session ops, etc.)
```

Complex logic lives in reusable scripts — not inside Stream Deck button definitions.

## Prerequisites

- macOS on Apple Silicon
- [Elgato Stream Deck](https://www.elgato.com/downloads) for macOS 7.5+
- [Stream Deck Mobile](https://apps.apple.com/app/stream-deck-mobile/id1476615877) on iPad
- Mac and iPad on the same Wi-Fi network
- zsh (default on modern macOS)
- Hammerspoon (window layouts)

## Installation

1. Clone or copy this project to `~/Documents/GitHub/ipad-stream-deck-console`.

2. Bootstrap config if needed:

   ```zsh
   cp config/config.example.json config/config.json
   # Replace YOUR_USERNAME and project paths
   ```

3. Validate:

   ```zsh
   zsh tests/validate-config.zsh
   chmod +x scripts/**/*.zsh tests/*.zsh
   ```

4. Install Stream Deck + Hammerspoon; pair the iPad ([pairing checklist](stream-deck/documentation/ipad-pairing-checklist.md)).

5. Backup, then build the primary Mobile profile:

   ```zsh
   zsh stream-deck/documentation/backup-stream-deck-config.zsh
   python3 scripts/stream-deck/build-profile.py --profile ipad-work
   ```

Full install notes: [INSTALLATION.md](stream-deck/documentation/INSTALLATION.md).

## Profiles

| Profile | Device | Role |
|---------|--------|------|
| **iPad Work Console** | Stream Deck Mobile | **Primary** — 8×4 · 2 pages (WORK + TOOLS) |
| **Operations Console** | Physical / hybrid | Physical deck layout |
| **iPad Console** | Stream Deck Mobile | Legacy folder layout — **rollback only** |

Canonical inventory: [ACTION-MAP.md](stream-deck/documentation/ACTION-MAP.md). Live ops: [STATUS.md](STATUS.md).

## Configuration

| File | Role |
|------|------|
| `config/config.json` | Runtime paths, projects, session/focus/ai (from `config.example.json` if missing) |
| `config/apps.json` | App catalog + `defaults.*` |
| `config/paths.json` | Legacy path shim — `sd_load_path` prefers `config.json` `paths.*` |
| `config/profiles-ipad-work.json` | Primary Mobile button metadata |
| `config/profiles-physical.json` | Physical / hybrid layout |
| `config/profiles.json` | Legacy Mobile folders |

### Defaults (`config/apps.json`)

Confirm current values in the file. Common keys: `chatgpt`, `terminal`, `claude_code`, `finance_spreadsheet`.

## Script Execution

```zsh
zsh scripts/launch/open-cursor.zsh
```

Runtime logs: `~/Library/Logs/AUTOGIO/StreamDeck/ipad-stream-deck-console.log`  
Health/diagnostics: `reports/`

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Button does nothing | Rebuild profile; Open `.command` launchers, not raw `.zsh` |
| App not found | `tests/validate-config.zsh`; fix `apps.json` / `config.json` |
| iPad won't connect | Same Wi-Fi; allow Local Network for Stream Deck |
| Wrong ChatGPT opens | Change `defaults.chatgpt` in `apps.json` |
| Start My Day blocked | Remove stale `~/.autogio/streamdeck/start-my-day.lockdir` |

## Backup and Restore

```zsh
zsh stream-deck/documentation/backup-stream-deck-config.zsh
```

Backups land in `backups/` (gitignored). Rollback: [ROLLBACK.md](stream-deck/documentation/ROLLBACK.md).

## Policy notes

- Cloud LLMs only (no LM Studio / Ollama)
- Git commit/push from the deck requires interactive confirmation; push is opt-in
- End Session may quit configured work apps when `session.quit_apps` is true
- File watcher (optional) watches `~/Reports` only

## Agents

See [AGENTS.md](AGENTS.md) for durable agent policy and [STATUS.md](STATUS.md) for pending ops.
