# Stream Deck Icons

Minimal category icons for the iPad Console profile.

## Format

| Property | Value |
|----------|-------|
| Format | SVG (export to PNG for Stream Deck) |
| Canvas | 144 × 144 px |
| Style | Dark background, high-contrast text labels |
| Labels | Short folder names (AI, macOS, Projects, etc.) |

## Files

| File | Use |
|------|-----|
| `folder-ai.svg` | AI folder |
| `folder-macos.svg` | macOS folder |
| `folder-projects.svg` | Projects folder |
| `folder-workspace.svg` | Workspace folder |
| `folder-safety.svg` | Safety / Diagnostics |
| `folder-audio.svg` | Audio folder (placeholder) |
| `folder-home.svg` | Home folder (placeholder) |

## Export to PNG (optional)

Stream Deck accepts PNG. Convert with Preview or:

```zsh
# Requires qlmanage or sips after opening SVG in Preview
for f in stream-deck/icons/*.svg; do
  echo "Export ${f} to 144x144 PNG via Preview: File → Export"
done
```

Individual button icons can use the same style or native app icons from `/Applications`.
