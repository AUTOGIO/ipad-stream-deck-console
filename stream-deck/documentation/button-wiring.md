# Button Wiring Guide

Wire each Stream Deck button to the thinnest action that works reliably.

## Recommended Action Types

| Priority | Stream Deck Action | Use when |
|----------|-------------------|----------|
| 1 | **Open** | Launching `.app` files directly |
| 2 | **System → Open** | Opening folders |
| 3 | **Open** (file) | Running `.zsh` or `.applescript` files |
| 4 | **Shortcuts** plugin | If native Open fails for scripts |

## Project Root

```
/Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console
```

## Button Wiring Table

### AI Folder

| Button | Stream Deck Action | Target |
|--------|-------------------|--------|
| ChatGPT | Open | `scripts/launch/open-chatgpt.zsh` |
| Claude Code | Open | `scripts/launch/open-claude-code.zsh` |
| Cursor | Open **or** native Open | `/Applications/Cursor.app` |
| LM Studio | Open **or** native Open | `/Applications/LM Studio.app` |
| Obsidian AI | Open | `scripts/launch/open-obsidian-ai.zsh` |

### macOS Folder

| Button | Stream Deck Action | Target |
|--------|-------------------|--------|
| Terminal | Open | `scripts/launch/open-terminal.zsh` |
| Home | System → Open | `/Users/eduardofgiovannini` |
| Health Check | Open | `scripts/system/health-check.zsh` |
| Activity Mon | Open | `scripts/launch/open-activity-monitor.zsh` |
| ActivityWatch | Open | `scripts/launch/open-activitywatch.zsh` |

### Projects Folder

| Button | Stream Deck Action | Target |
|--------|-------------------|--------|
| GitHub Dir | System → Open | `/Users/eduardofgiovannini/Documents/GitHub` |
| Pick Project | Open | `applescript/project-selector.applescript` |

### Workspace Folder

| Button | Stream Deck Action | Target |
|--------|-------------------|--------|
| AI Eng | Open | `scripts/workspace/ai-engineering.zsh` |
| Finance | Open | `scripts/workspace/finance.zsh` |

### Safety

| Button | Stream Deck Action | Target |
|--------|-------------------|--------|
| Diagnostics | Open | `scripts/system/collect-diagnostics.zsh` |

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
