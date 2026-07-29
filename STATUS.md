# STATUS

Last updated: 2026-07-29 (audit remediation)

## Discovery Status

- **Machine:** MacBook Air M4, macOS 27.0, 16 GB RAM
- **Stream Deck macOS:** Installed at `/Applications/Elgato Stream Deck.app`
- **Stream Deck version:** 7.5.0.22885
- **Project directory:** `~/Documents/GitHub/ipad-stream-deck-console`
- **Runtime:** `~/Library/Application Support/AUTOGIO/streamdeck/`
- **Logs:** `~/Library/Logs/AUTOGIO/StreamDeck/`
- **Git remote:** **None configured yet** — add a private `origin` when ready (do not push `backups/` or secrets)

## LLM policy

**Cloud APIs only.** ChatGPT, Atlas, Claude, Codex, Gemini, and Perplexity.
Local runtimes **LM Studio** and **Ollama** are removed. **Grok is omitted from iPad Work Console.**

## Stream Deck Profile

| Profile | Device | Layout |
|---------|--------|--------|
| **iPad Work Console** | Stream Deck Mobile | **8×4 · 2 pages** (WORK + TOOLS) — primary |
| **iPad Console** | Stream Deck Mobile | Legacy folder layout — rollback only |
| **Operations Console** | Physical / hybrid | hybrid folder layout |

Config source for primary mobile: `config/profiles-ipad-work.json`  
Build: `python3 scripts/stream-deck/build-profile.py --profile ipad-work`

## Ultrawide Command Center

For the 3840×1080 AG493QS4R4, Command Center is the default work layout:

- 15% ChatGPT Atlas · 42% Cursor · 28% Ghostty · 15% Apple Notes
- The Notes rail opens the native `AUTOGIO/Command Center Inbox` note.
- START MY DAY opens the active Cursor project, Atlas, Ghostty at that project root, and the capture note.
- END SESSION keeps a plain-language personal journal in `~/Reports/WorkSessions`; it uses the open Cursor workspace when unambiguous, writes its generated snapshot to that project's `reports/session/` directory, then requests a normal quit for Cursor, Atlas, Ghostty, and Notes when `session.quit_apps` is true. Unsaved-work prompts remain under each app's control.
- Optional file watcher notifies for changes under **`~/Reports` only** (not `~/Documents`).

## Verified notes (2026-07-29)

- ChatGPT.app bundle ID on this Mac is `com.openai.codex` (confirmed via `mdls`) — `apps.json` is correct.
- Clone bootstrap: copy `config/config.example.json` → `config/config.json` and edit paths.

## Pending User Steps

1. In Stream Deck macOS → Profiles → **Stream Deck Mobile** → select **iPad Work Console**.
2. On iPad: confirm pages **WORK** and **TOOLS** are visible.
3. Spot-check: START MY DAY, NOTES, FOCUS SESSION, RESET, and CURRENT PROJECT.
4. When ready: add a private Git remote for offsite backup of this repo.

## Next Recommended Action

Select **iPad Work Console** on Mobile and verify the four-panel Command Center on the ultrawide.
