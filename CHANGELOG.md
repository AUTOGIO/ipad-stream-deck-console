# Changelog

All notable changes to ipad-stream-deck-console.

## 2026-07-29

### Fixed

- Diagnostics archive now copies config from `${SD_ROOT}` (was undefined `${root}`).
- Health-check test asserts the newest report by mtime.
- Stream Deck `commit-push` requires interactive confirmation, blocks secret-like paths, and makes push opt-in; refuses `SD_SKIP_DIALOGS=1`.
- Stream Deck `pull-latest` confirms project/branch and no longer uses `--autostash` by default; refuses non-interactive runs.
- Lock acquisition uses atomic `mkdir` lockdirs.
- Path resolution prefers `config.json` `paths.*` over `paths.json`; aligned `paths.json` `logs_dir` with AUTOGIO logs.
- Slim Stream Deck backups (Profiles/Preferences only; dynamic project root).

### Changed

- File watcher watches `~/Reports` only (no longer `~/Documents`).
- Primary docs (README, INSTALLATION, pairing, profile-setup) center **iPad Work Console**; legacy iPad Console is rollback-only.
- Added `config/config.example.json` for clone bootstrap.
- `.gitignore` covers `.cursor/`, `.memory/`, and `stream-deck/generated copy/`.
- Removed abandoned `stream-deck/generated copy/` and pruned oversized historical Elgato full-tree backups.

### Notes

- ChatGPT.app bundle ID on this machine is `com.openai.codex` (verified) — not Classic `com.openai.chat`.
- End Session quit policy: when `session.quit_apps` is true, End Session quits the configured START MY DAY apps (supersedes the 2026-07-23 “never quit” Focus/End note below).

## 2026-07-25

### Changed

- Replaced Obsidian workflow buttons and vault dependencies with native Apple Notes.
- START MY DAY now opens the active project, ChatGPT Atlas, Ghostty, and `AUTOGIO/Command Center Inbox`.
- Ghostty now opens at the active Cursor workspace root; project aliases remain convenience shortcuts only.
- END SESSION now normally quits the four START MY DAY applications (Cursor, ChatGPT Atlas, Ghostty, and Notes) after recording the report. Each app retains its standard unsaved-work confirmation.
- END SESSION now reports a clear native success or attention notification instead of technical log details.
- The native `~/Reports` watcher alerts for newly saved files and content updates (Documents scope removed 2026-07-29).
- The central Daily Operations Log now records each End Session in plain language, with a readable project status and clear completed, remaining, and next-action fields.
- Command Center on the AG493QS4R4 now uses Atlas 15% · Cursor 42% · Ghostty 28% · Notes 15%.
- Removed low-value Focus Mode, Shutdown Workspace, and Shortcuts paste-helper actions.
- END SESSION snapshots are now owned by the active project (`reports/session/`) while the personal daily journal remains centralized.

## 2026-07-23

### Added

- **iPad Work Console** profile: flat **8×4 × 2 pages** (`config/profiles-ipad-work.json`)
- Session ops: CURRENT PROJECT, FOCUS SESSION, AI STATUS, RESTART AI, END SESSION
- Daily launchers: Chrome, Gmail, Google Drive (web), WhatsApp, Telegram, NotebookLM, Desktop Commander
- Builder flag: `--profile ipad-work` (leaves legacy `iPad Console` intact)

### Changed

- ACTION-MAP / STATUS: Mobile primary layout is Work/Tools pages (no Grok on this profile)
- Focus Session: hide configured apps only — never quit (End Session quit behavior superseded 2026-07-25 / clarified 2026-07-29)

## 2026-07-14

### Removed

- LM Studio and Ollama from apps/paths/config, launch scripts, profiles, health-check, diagnostics, and status snapshot
- Policy: cloud LLM APIs only (ChatGPT, Atlas, Claude, Codex, Gemini, Grok, Perplexity)

## 2026-07-11 (GATE 5)

### Added

- `scripts/stream-deck/build-profile.py` — automated iPad Console profile builder
- Post-install Stream Deck backup
- `reports/acceptance-test_2026-07-11.md` — Mac-side acceptance results

### Changed

- Preferred Stream Deck profile set to **iPad Console** (`165de6f1-0152-4515-a13f-19853bec67ab`)
- STATUS.md updated for GATE 5 completion

### Notes

- iPad pairing requires user verification in Stream Deck Mobile
- Stream Deck listens on port 28198 for mobile connections

## 2026-07-11 (GATE 2–4)

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
