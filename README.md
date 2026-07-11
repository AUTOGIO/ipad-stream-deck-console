# iPad Stream Deck Console

Turn an iPad running **Stream Deck Mobile** into a reliable control surface for Mac workflows.

## Objective

The iPad is the control surface. The Mac executes workflows through thin actions (Shortcuts, AppleScript, or zsh scripts) stored in this repository.

## Architecture

```
iPad Stream Deck Mobile
        ↓
Elgato Stream Deck (macOS)
        ↓
Thin button action (Open / Shortcut / AppleScript / Shell)
        ↓
Script in ipad-stream-deck-console
        ↓
Actual workflow (launch app, open folder, report, etc.)
```

Complex logic lives in reusable scripts — not inside Stream Deck button definitions.

## Prerequisites

- macOS on Apple Silicon
- [Elgato Stream Deck](https://www.elgato.com/downloads) for macOS (GATE 5)
- [Stream Deck Mobile](https://apps.apple.com/app/stream-deck-mobile/id1476615877) on iPad (GATE 5)
- Mac and iPad on the same Wi-Fi network
- zsh (default on modern macOS)

## Installation

1. Clone or copy this project to:

   `/Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console`

2. Validate configuration:

   ```zsh
   zsh /Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console/tests/validate-config.zsh
   ```

3. Make scripts executable:

   ```zsh
   chmod +x /Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console/scripts/**/*.zsh
   chmod +x /Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console/tests/*.zsh
   ```

4. Install Stream Deck on macOS from [Elgato Downloads](https://www.elgato.com/downloads) and pair the iPad (see `stream-deck/documentation/ipad-pairing-checklist.md`).

   Stream Deck Mobile (iPad): [App Store](https://apps.apple.com/app/stream-deck-mobile/id1476615877)

## iPad Pairing

See [stream-deck/documentation/ipad-pairing-checklist.md](stream-deck/documentation/ipad-pairing-checklist.md).

## Profile Structure

Six primary folders plus Safety:

| Folder | Purpose |
|--------|---------|
| AI | ChatGPT, Claude Code, Cursor, LM Studio, Obsidian |
| macOS | Terminal, Finder, health check, Activity Monitor, ActivityWatch |
| Projects | GitHub directory, project selector |
| Audio | Placeholder (Phase 2) |
| Home | Placeholder (Phase 2) |
| Workspace | AI Engineering, Finance workspaces |
| Safety | Collect diagnostics |

Button wiring details: [stream-deck/documentation/button-wiring.md](stream-deck/documentation/button-wiring.md).

## Button Inventory

| # | Folder | Label | Script |
|---|--------|-------|--------|
| 1 | AI | ChatGPT | `scripts/launch/open-chatgpt.zsh` |
| 2 | AI | Claude Code | `scripts/launch/open-claude-code.zsh` |
| 3 | AI | Cursor | `scripts/launch/open-cursor.zsh` |
| 4 | AI | LM Studio | `scripts/launch/open-lm-studio.zsh` |
| 5 | AI | Obsidian AI | `scripts/launch/open-obsidian-ai.zsh` |
| 6 | macOS | Terminal | `scripts/launch/open-terminal.zsh` |
| 7 | macOS | Home | `scripts/launch/open-finder-home.zsh` |
| 8 | macOS | Health Check | `scripts/system/health-check.zsh` |
| 9 | macOS | Activity Mon | `scripts/launch/open-activity-monitor.zsh` |
| 10 | macOS | ActivityWatch | `scripts/launch/open-activitywatch.zsh` |
| 11 | Projects | GitHub Dir | `scripts/launch/open-github-projects.zsh` |
| 12 | Projects | Pick Project | `applescript/project-selector.applescript` |
| 13 | Workspace | AI Eng | `scripts/workspace/ai-engineering.zsh` |
| 14 | Workspace | Finance | `scripts/workspace/finance.zsh` |
| 15 | Safety | Diagnostics | `scripts/system/collect-diagnostics.zsh` |

## Configuration

Edit these files — never hardcode paths in multiple scripts:

- `config/apps.json` — application names, bundle IDs, paths, defaults
- `config/paths.json` — canonical filesystem paths
- `config/profiles.json` — button metadata for Stream Deck setup

### Defaults (change in `config/apps.json`)

| Key | Current value | Purpose |
|-----|---------------|---------|
| `chatgpt` | `chatgpt_atlas` | Which ChatGPT app to open |
| `terminal` | `ghostty` | Default terminal |
| `claude_code` | `cursor_ai_engineering` | Claude Code button behavior |
| `finance_spreadsheet` | `excel` | Finance workspace spreadsheet |

## Script Execution

All scripts use shared libraries in `scripts/lib/`:

```zsh
zsh /Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console/scripts/launch/open-cursor.zsh
```

Logs are written to `logs/ipad-stream-deck-console.log`.

## Logs

- Runtime log: `logs/ipad-stream-deck-console.log`
- Health reports: `reports/health-check_YYYY-MM-DD_HH-MM-SS.txt`
- Diagnostics archives: `reports/diagnostics_YYYY-MM-DD_HH-MM-SS.zip`

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Button does nothing | Run the script directly in Terminal; check `logs/` |
| App not found | Run `tests/validate-config.zsh`; update `config/apps.json` |
| iPad won't connect | Same Wi-Fi, Stream Deck running, allow local network |
| Firewall blocks pairing | System Settings → Network → Firewall → allow Stream Deck |
| Wrong ChatGPT opens | Change `defaults.chatgpt` in `config/apps.json` |

## Backup and Restore

Before changing Stream Deck profiles:

1. Back up Elgato config (see `stream-deck/documentation/backup-restore.md`)
2. Store backups in `backups/` (not committed to Git)

## Uninstallation

1. Remove Stream Deck profile buttons pointing to this project
2. Delete or archive `~/Documents/GitHub/ipad-stream-deck-console`
3. Uninstall Stream Deck apps if no longer needed

## Known Limitations

- Phase 1 launches apps only — no window positioning
- Stream Deck macOS must be installed for iPad pairing
- Hammerspoon integration deferred to Phase 2
- Audio and Home folders are placeholders
- Diagnostics require user confirmation before archiving

## Future Improvements

- Window positioning via Hammerspoon
- Stream Deck status feedback
- Home Assistant and Wave Link controls
- Dynamic button states
- Context-aware profile switching
