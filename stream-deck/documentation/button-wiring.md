# Button Wiring Guide

Wire each Stream Deck button to the thinnest action that works reliably.

## Recommended Action Types

| Priority | Stream Deck Action | Use when |
|----------|-------------------|----------|
| 1 | **Open** | Launching `.app` files directly |
| 2 | **System → Open** | Opening folders |
| 3 | **Open** (`.command` file) | Running zsh scripts via generated `.command` launchers |
| 4 | **Open** (URL) | Hammerspoon `hammerspoon://` actions |
| 5 | **Shortcuts** plugin | If native Open fails for scripts |

## Project Root

```
/Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console
```

## Operations Console Home (physical)

Source of truth: `config/profiles-physical.json`

### Row 0 — daily core

| Button | Stream Deck Action | Target |
|--------|-------------------|--------|
| START MY DAY | Open | `scripts/workspace/start-my-day.zsh` |
| Cursor | Open | `scripts/launch/open-cursor.zsh` |
| ChatGPT | Open | `scripts/launch/open-chatgpt.zsh` → ChatGPT.app |
| Claude | Open | `scripts/launch/open-claude.zsh` → Claude.app |
| Atlas | Open | `scripts/launch/open-chatgpt-atlas.zsh` |
| iTerm | Open | `scripts/launch/open-terminal.zsh` (defaults → iTerm) |
| Notes | Open | `scripts/launch/open-notes.zsh` |
| Codex | Open | `scripts/launch/open-codex.zsh` |

### Row 1 — workspaces / ops

| Button | Stream Deck Action | Target |
|--------|-------------------|--------|
| Dev Space | Open | `scripts/workspace/development-workspace.zsh` |
| AI Space | Open | `scripts/workspace/ai-engineering.zsh` |
| Thinking | Open | `scripts/workspace/thinking-workspace.zsh` → `spencer --restore "THINKING_WORKSPACE"` |
| Health | Open | `scripts/system/health-check.zsh` |
| RESET LAYOUT | Open | `scripts/workspace/reset-daily-layout.zsh` |
| Hammerspoon | Open | `scripts/projects/open-project.zsh hammerspoon` |
| Status | Open | `scripts/system/status-snapshot.zsh` |

### Row 2 — folders

AI | Dev | Projects | Research | macOS | System | Prompts | GitHub

Secondary tools (ActivityWatch, Calendar, Mail) live in folders only. Local LLMs (LM Studio / Ollama) are **not** used — cloud APIs only.

## Folder Highlights

### AI Folder

| Button | Target |
|--------|--------|
| Gemini | `scripts/launch/open-gemini.zsh` |
| Grok | Browser → grok.com |
| Perplexity | Browser → perplexity.ai |
| ChatGPT | `scripts/launch/open-chatgpt.zsh` |
| Atlas | `scripts/launch/open-chatgpt-atlas.zsh` |
| Codex | `scripts/launch/open-codex.zsh` |

### Development Folder

| Button | Target |
|--------|--------|
| Ghostty | `scripts/launch/open-ghostty.zsh` (exact Ghostty, not iTerm) |
| Claude | `scripts/launch/open-claude.zsh` |

### iPad Console (mobile) — legacy rollback only

Primary Mobile profile is **iPad Work Console** (`--profile ipad-work`). Use this section only for rollback wiring.

| Button | Stream Deck Action | Target |
|--------|-------------------|--------|
| ChatGPT | Open | `scripts/launch/open-chatgpt.zsh` |
| Claude | Open | `scripts/launch/open-claude.zsh` |
| Cursor | Open | `scripts/launch/open-cursor.zsh` |
| Notes | Open | `scripts/launch/open-notes.zsh` |
| iTerm | Open | `scripts/launch/open-terminal.zsh` |
| Home | System → Open | `/Users/eduardofgiovannini` |
| Health Check | Open | `scripts/system/health-check.zsh` |
| Activity Mon | Open | `scripts/launch/open-activity-monitor.zsh` |
| ActivityWatch | Open | `scripts/launch/open-activitywatch.zsh` |
| GitHub Dir | System → Open | `/Users/eduardofgiovannini/Documents/GitHub` |
| Pick Project | Open | `applescript/project-selector.applescript` |
| AI Eng | Open | `scripts/workspace/ai-engineering.zsh` |
| Finance | Open | `scripts/workspace/finance.zsh` |
| Diagnostics | Open | `scripts/system/collect-diagnostics.zsh` |

## Shell Scripts via Stream Deck

macOS does **not** execute `.zsh` files when opened — Stream Deck's Open action uses `open`, which only runs `.command` files in Terminal.

`build-profile.py` generates `.command` launchers in `stream-deck/generated/commands/` automatically. Rebuild after config changes:

```zsh
python3 scripts/stream-deck/build-profile.py --profile all
```

## Making Scripts Executable

Stream Deck "Open" on scripts requires execute permission:

```zsh
chmod +x /Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console/scripts/**/*.zsh
```

## Shell Script Action (Alternative)

If "Open" does not execute `.zsh` files:

1. Add action: **System → Open**
2. Or use **Execute Shell Script** (if available via plugin) with:

```zsh
zsh /Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console/scripts/launch/open-cursor.zsh
```

## Icons

Place icons from `stream-deck/icons/` on each button. Recommended size: **144×144 PNG** (Stream Deck standard).

## Testing Order

1. Test each script in Terminal first
2. Wire one button and test from Stream Deck on Mac
3. Verify from iPad Stream Deck Mobile
4. Add remaining buttons
