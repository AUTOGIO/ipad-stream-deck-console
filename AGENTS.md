# AGENTS.md

Instructions for AI coding agents working on **ipad-stream-deck-console**.

This file is durable project orientation. For live session state, pending user steps, and current deploy status, read [`STATUS.md`](STATUS.md) first and prefer it over any snapshot here.

---

## What this project is

Turn an iPad (Stream Deck Mobile) and/or a physical Stream Deck into a Mac control surface. Buttons stay thin; all real logic lives in this repo as zsh scripts, AppleScript, Shortcuts, or Hammerspoon URL actions.

```
iPad / Physical Stream Deck
        ↓
Elgato Stream Deck (macOS)
        ↓
Thin action (Open / .command / hammerspoon:// / Shortcut)
        ↓
Script in this repository
        ↓
Workflow (launch app, open project, layout, session ops, etc.)
```

**Audience of this file:** agents about to change scripts, config, profiles, or docs — not end users installing the console (see [`README.md`](README.md)).

---

## Stack and environment

| Item | Value |
|------|--------|
| OS | macOS on Apple Silicon |
| Shell | zsh (`set -euo pipefail` on scripts) |
| Profile builder | Python 3 (`scripts/stream-deck/build-profile.py`) |
| Window layouts | Hammerspoon (`hammerspoon://…`) |
| Stream Deck | Elgato Stream Deck macOS 7.5+ |
| Project root | `/Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console` |

### Runtime locations (created on use)

| Purpose | Path |
|---------|------|
| Runtime state | `~/Library/Application Support/AUTOGIO/streamdeck/` |
| Logs | `~/Library/Logs/AUTOGIO/StreamDeck/` |
| Repo reports | `reports/` (health, diagnostics) |
| Session log | `~/Reports/WorkSessions/Daily Operations Log.md` |
| Elgato app support | `~/Library/Application Support/com.elgato.StreamDeck/` |
| Backups (local only) | `backups/` — never commit |

Paths may also be mirrored in `config/config.json` → `paths.*`. Prefer reading config over hardcoding.

---

## Hard constraints (do not violate)

1. **Cloud LLMs only.** Supported: ChatGPT, Atlas, Claude, Codex, Gemini, Grok, Perplexity. **Do not** reintroduce LM Studio, Ollama, or other local LLM runtimes into config, scripts, profiles, health checks, or docs.
2. **Thin Stream Deck buttons.** Put branching, detection, and multi-step logic in scripts under `scripts/`, not inside Stream Deck button definitions.
3. **Config is the source of truth.** App names, bundle IDs, paths, defaults, projects, focus/session/ai blocks live in JSON. Do not scatter absolute paths across many scripts.
4. **Init correctly.** Call `sd_init_from_script` directly in the script process — **never** inside `$()` / a subshell (that drops logging globals).
5. **Buttons use generated launchers.** Prefer Open on `.command` launchers produced by the profile builder — not raw `.zsh` when Stream Deck Open fails or PATH is empty.
6. **Backup before profile writes.** Before `build-profile.py` or manual Elgato config edits, run the backup script (see Profiles below).
7. **Tests are non-interactive when possible.** Export `SD_SKIP_DIALOGS=1` for automated runs.
8. **No secrets in git.** Do not commit credentials, `.env` with secrets, Elgato backups, or live log dumps.

---

## Repository map

```
config/           # apps.json, paths.json, config.json, profiles*.json
scripts/
  lib/            # common.zsh, logging.zsh, app_detection.zsh
  launch/         # open-* app/path launchers
  workspace/      # start-my-day, focus, end-session, layouts, spaces
  system/         # health, diagnostics, status, display/layout detect
  projects/       # open/set current project
  stream-deck/    # build-profile.py, login item helpers
  git/            # commit-push, pull-latest helpers
  hammerspoon/    # invoke / AI prompt bridges
  obsidian/       # daily note, vault backup
applescript/      # e.g. project-selector.applescript
layouts/          # display layout JSON (single/dual/safe)
stream-deck/      # icons, documentation, built profile metadata
tests/            # validate-config + behavioral smoke tests
reports/          # generated health/diagnostics (keep .gitkeep)
backups/          # local Stream Deck backups (not committed)
shortcuts/        # Shortcut-related notes
docs/             # design specs (e.g. superpowers/specs)
```

---

## Configuration sources of truth

| File | Role |
|------|------|
| `config/config.json` | Runtime paths, projects map, layouts, focus/session/ai/current_project blocks, feature flags |
| `config/apps.json` | App catalog + `defaults.*` (which ChatGPT/terminal/etc. to open) |
| `config/paths.json` | Canonical filesystem paths used by older/shared helpers |
| `config/profiles.json` | Mobile / iPad Console button metadata for the builder |
| `config/profiles-physical.json` | Physical / hybrid Operations Console layout |

**Rule:** when adding an app or path, update the JSON first, then the launcher/workspace script, then the profile JSON, then rebuild.

Defaults agents commonly touch live under `apps.json` → `defaults` (e.g. `chatgpt`, `terminal`, `claude_code`, `finance_spreadsheet`). Confirm current values in the file — do not trust README tables if they disagree.

---

## Script conventions

### Minimal launcher pattern

```zsh
#!/bin/zsh
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"
sd_launch_configured_app "$SD_APPS_JSON" "cursor"
```

Adjust the relative `../lib` depth for scripts not directly under `scripts/<area>/` (always resolve to `scripts/lib/common.zsh`).

### Shared libraries

| Library | Use for |
|---------|---------|
| `scripts/lib/common.zsh` | Init, PATH bootstrap, open helpers, JSON/config getters, Focus/Shortcuts helpers |
| `scripts/lib/logging.zsh` | `sd_log_info` / `sd_log_error` → runtime log file |
| `scripts/lib/app_detection.zsh` | Detect installed apps / resolve configured keys |

After `sd_init_from_script`:

- `SD_ROOT`, `SD_CONFIG_JSON`, `SD_APPS_JSON`, `SD_PATHS_JSON`
- Log file under configured `paths.logs_dir` when set

### Script areas (intent)

| Directory | Intent |
|-----------|--------|
| `launch/` | Open one app or configured path |
| `workspace/` | Multi-app day/session flows, layouts, shutdown |
| `system/` | Health, status snapshot, diagnostics, displays |
| `projects/` | Current project pointer + open by key |
| `stream-deck/` | Profile build, login items, prune helpers |
| `git/` | Thin git helpers wired to buttons |
| `obsidian/` | Vault daily note / backup |
| `hammerspoon/` | Bridge to Hammerspoon actions |

### Dialogs and safety

- Destructive or noisy flows (diagnostics archive, shutdown, focus) may show UI confirmations.
- Agents and CI: `export SD_SKIP_DIALOGS=1`.
- Focus Session: hide distractors; do not quit apps that are “hide-never-quit”.
- End Session: may quit configured work apps — treat as destructive.

---

## Profiles and Stream Deck

### Profiles

| Profile | Device | Config source |
|---------|--------|----------------|
| **iPad Work Console** | Stream Deck Mobile (primary) | `config/profiles-ipad-work.json` (8×4 × 2 flat pages) |
| **iPad Console** | Stream Deck Mobile (legacy) | `config/profiles.json` folder layout |
| **Operations Console** | Physical / hybrid | `config/profiles-physical.json` |

Canonical button inventory: [`stream-deck/documentation/ACTION-MAP.md`](stream-deck/documentation/ACTION-MAP.md)  
Wiring priorities: [`stream-deck/documentation/button-wiring.md`](stream-deck/documentation/button-wiring.md)

### Condensed physical home (theme only)

| Row | Theme |
|-----|--------|
| 1 | Daily launch (START MY DAY, AI apps, Cursor, Terminal, Obsidian) |
| 2 | Session ops (CURRENT PROJECT, FOCUS, AI STATUS, RESTART AI, END SESSION) + Dev/Thinking/RESET |
| 3 | Folder entry (AI, Dev, Projects, Research, macOS, System, Prompts, GitHub) |

Full per-button targets stay in ACTION-MAP / profile JSON — do not invent labels.

### Build / rebuild

```zsh
# Always backup first
zsh stream-deck/documentation/backup-stream-deck-config.zsh

# Physical, mobile, or both
python3 scripts/stream-deck/build-profile.py --profile physical
python3 scripts/stream-deck/build-profile.py --profile all
```

Builder may quit/relaunch Stream Deck. After build, select the correct profile in the Elgato app (Operations Console vs iPad Console).

Login-at-startup helpers:

```zsh
zsh scripts/stream-deck/configure-streamdeck-login.zsh
zsh scripts/stream-deck/remove-streamdeck-login.zsh   # rollback
```

Rollback details: [`stream-deck/documentation/ROLLBACK.md`](stream-deck/documentation/ROLLBACK.md)

### Action type priority (when wiring manually)

1. Open `.app`
2. Open folder
3. Open generated `.command` launcher for scripts
4. Open `hammerspoon://…` URL
5. Shortcuts plugin only if Open fails

---

## Layouts and displays

Layout JSON lives in `layouts/`:

| Scenario | Layout file / mode |
|----------|-------------------|
| Ultrawide / external only | `single_external` |
| Built-in only | `single_builtin` |
| Both | `dual_display` |
| Unknown / fallback | `safe_layout` |

Detection and selection: `scripts/system/detect-displays.zsh`, `scripts/system/select-layout.zsh`.  
Hammerspoon applies window positions; scripts orchestrate when to call which action. See ACTION-MAP “Hammerspoon Layout Actions”.

---

## Verification commands

Run from project root. Prefer these after config or launcher changes:

```zsh
zsh tests/validate-config.zsh
export SD_SKIP_DIALOGS=1
zsh tests/test-launchers.zsh
zsh tests/test-health-check.zsh
zsh tests/test-layout-scripts.zsh
zsh tests/test-start-my-day.zsh
```

Manual MVP matrix: [`stream-deck/documentation/TESTING.md`](stream-deck/documentation/TESTING.md)  
Install path: [`stream-deck/documentation/INSTALLATION.md`](stream-deck/documentation/INSTALLATION.md)  
iPad pairing: [`stream-deck/documentation/ipad-pairing-checklist.md`](stream-deck/documentation/ipad-pairing-checklist.md)

Make new scripts executable:

```zsh
chmod +x scripts/**/*.zsh tests/*.zsh
```

---

## Boundaries — do / don't

### Do

- Update JSON config before wiring new buttons
- Reuse `sd_*` helpers from `scripts/lib/`
- Keep launchers small; put multi-step flows in `workspace/` or `system/`
- Update ACTION-MAP + STATUS when behavior or pending ops change
- Append notable changes to `CHANGELOG.md`
- Point agents/humans at STATUS for “what’s next”

### Don't

- Hardcode `/Users/...` in new scripts when `config.json` / `paths.json` already holds the value
- Commit `backups/`, large `reports/*.zip`, or runtime logs
- Wire Stream Deck to fragile multi-line inline scripts
- Quit apps in Focus flows that should only hide
- Assume README button tables are newer than ACTION-MAP / profile JSON
- Add local LLM tooling “for convenience”

---

## What to read before modifying each area

| Task | Read first |
|------|------------|
| Any ops / “what’s broken” | `STATUS.md` |
| New or changed button | `ACTION-MAP.md`, then matching `config/profiles*.json` |
| Launch / open app | `config/apps.json`, existing `scripts/launch/open-*.zsh` |
| Paths / projects | `config/config.json`, `config/paths.json` |
| Session ops (focus, AI status, end) | `STATUS.md` Session Ops section, `config/config.json` (`focus`, `session`, `ai`, `current_project`) |
| Profile build / Elgato | `INSTALLATION.md`, `button-wiring.md`, `ROLLBACK.md` |
| Layouts / displays | `layouts/*.json`, `TESTING.md` display scenarios |
| Shared helpers | `scripts/lib/common.zsh` |
| Product overview | `README.md` |
| Design history | `docs/superpowers/specs/` |

---

## Troubleshooting cues for agents

| Symptom | Likely cause / fix |
|---------|-------------------|
| Button does nothing | Rebuild profile; ensure `.command` Open target; Stream Deck running |
| App not found | `tests/validate-config.zsh`; fix `apps.json` / `config.json` |
| Logs empty | Init was in a subshell — use `sd_init_from_script` in-process |
| Wrong ChatGPT/terminal | Change `defaults.*` in `apps.json` |
| iPad won’t pair | Same Wi-Fi; allow local network; see pairing checklist |
| Start My Day blocked | Lock file — see ROLLBACK lock cleanup |
| Profile disaster | Restore from `backups/` per ROLLBACK.md |

---

## Git and docs hygiene

- Commit only when the user asks.
- Prefer updating existing docs (`STATUS`, `CHANGELOG`, ACTION-MAP) over creating new markdown files.
- Keep this `AGENTS.md` aligned with durable policy; put ephemeral “pending steps” only in `STATUS.md`.
- When policy changes (e.g. LLM allowlist, init rules), update this file in the same change set.

## Reusable AI templates (other projects)

Generic cleanup prompt and new-project `AGENTS.md` live in [`templates/ai/`](templates/ai/README.md). Use those for GMC, Fulofilo, and new repos — do not copy this Stream Deck–specific file wholesale.

---

## Quick command cheat sheet

```zsh
cd /Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console

zsh tests/validate-config.zsh
SD_SKIP_DIALOGS=1 zsh tests/test-launchers.zsh

zsh stream-deck/documentation/backup-stream-deck-config.zsh
python3 scripts/stream-deck/build-profile.py --profile physical

# Example single action
zsh scripts/launch/open-cursor.zsh
zsh scripts/system/health-check.zsh
```
