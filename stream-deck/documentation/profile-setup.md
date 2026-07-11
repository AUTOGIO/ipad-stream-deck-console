# Manual Profile Setup Guide

Create the **iPad Console** profile in Stream Deck before iPad pairing.

## 1. Create Profile

1. Open **Elgato Stream Deck**
2. Click profile dropdown → **Add Profile**
3. Name: `iPad Console`

## 2. Create Folder Buttons

Add a **Folder** action for each category on the main page:

| Folder Button | Icon |
|---------------|------|
| AI | `stream-deck/icons/folder-ai.svg` |
| macOS | `stream-deck/icons/folder-macos.svg` |
| Projects | `stream-deck/icons/folder-projects.svg` |
| Audio | `stream-deck/icons/folder-audio.svg` |
| Home | `stream-deck/icons/folder-home.svg` |
| Workspace | `stream-deck/icons/folder-workspace.svg` |

Add a **Safety** button (folder or single) for Diagnostics.

## 3. Wire Buttons Inside Each Folder

Use absolute paths. Project root:

```
/Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console
```

See [button-wiring.md](button-wiring.md) for the full table.

### Quick Reference — AI Folder

| Label | Action Type | Target |
|-------|-------------|--------|
| ChatGPT | Open file | `.../scripts/launch/open-chatgpt.zsh` |
| Claude Code | Open file | `.../scripts/launch/open-claude-code.zsh` |
| Cursor | Open | `/Applications/Cursor.app` |
| LM Studio | Open | `/Applications/LM Studio.app` |
| Obsidian AI | Open file | `.../scripts/launch/open-obsidian-ai.zsh` |

### Quick Reference — macOS Folder

| Label | Action Type | Target |
|-------|-------------|--------|
| Terminal | Open file | `.../scripts/launch/open-terminal.zsh` |
| Home | Open | `/Users/eduardofgiovannini` |
| Health Check | Open file | `.../scripts/system/health-check.zsh` |
| Activity Mon | Open | Activity Monitor.app |
| ActivityWatch | Open file | `.../scripts/launch/open-activitywatch.zsh` |

### Quick Reference — Projects Folder

| Label | Action Type | Target |
|-------|-------------|--------|
| GitHub Dir | Open | `/Users/eduardofgiovannini/Documents/GitHub` |
| Pick Project | Open file | `.../applescript/project-selector.applescript` |

### Quick Reference — Workspace Folder

| Label | Action Type | Target |
|-------|-------------|--------|
| AI Eng | Open file | `.../scripts/workspace/ai-engineering.zsh` |
| Finance | Open file | `.../scripts/workspace/finance.zsh` |

### Safety

| Label | Action Type | Target |
|-------|-------------|--------|
| Diagnostics | Open file | `.../scripts/system/collect-diagnostics.zsh` |

## 4. Set iPad Layout

1. In Stream Deck, switch device view to **iPad** (when connected)
2. Ensure folder pages fit the iPad grid
3. Use short labels (≤10 characters) for legibility

## 5. Export Profile (Optional)

1. Right-click profile → **Export**
2. Save to `stream-deck/profiles/ipad-console.streamDeckProfile`
3. File is gitignored (binary)

## 6. Verify on Mac First

Press each button on the Mac Stream Deck app before testing from iPad.
