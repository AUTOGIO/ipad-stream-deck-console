# Changelog

All notable changes to ipad-stream-deck-console.

## 2026-07-11

### Added

- GATE 2: Project foundation with `config/apps.json`, `config/paths.json`, `config/profiles.json`
- Shared libraries: `scripts/lib/common.zsh`, `logging.zsh`, `app_detection.zsh`
- Configuration validator: `tests/validate-config.zsh`
- GATE 3: Five launch scripts (Cursor, LM Studio, ActivityWatch, Finder home, GitHub dir)
- GATE 4: Health check, project selector, workspace launchers, diagnostics collector
- Documentation: README, STATUS, pairing checklist, button wiring, backup/restore
- Minimal Stream Deck icon placeholders

### Fixed

- Script initialization: `sd_init_from_script` replaces subshell-based init (logging now works from Stream Deck)

### Notes

- Stream Deck macOS not installed; profile wiring documented for GATE 5
- Defaults: ChatGPT Atlas, Ghostty terminal, Cursor+AI_Engineering for Claude Code
