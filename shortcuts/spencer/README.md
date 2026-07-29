# Spencer desktop layout Shortcuts

Replica of your **Start My Day** Shortcut for every Spencer desktop layout.

## Shell body (same as Start My Day)

```zsh
open -a Spencer
for i in {1..20}; do
  if /Applications/Spencer.app/Contents/MacOS/SpencerCLI --list >/dev/null 2>&1; then
    /Applications/Spencer.app/Contents/MacOS/SpencerCLI --restore "<LAYOUT>" --launch-apps=true
    exit $?
  fi
  sleep 0.5
done
echo "Spencer CLI did not become ready" >&2
exit 1
```

## Files

| Layout | Paste-ready script | Signed Shortcut file |
|--------|--------------------|----------------------|
| CLEANUP | `CLEANUP.zsh` | `CLEANUP.shortcut` |
| DESKTOP_COMMANDER | `DESKTOP_COMMANDER.zsh` | `DESKTOP_COMMANDER.shortcut` |
| NOTEBOOKLM | `NOTEBOOKLM.zsh` | `NOTEBOOKLM.shortcut` |
| PRINT_FACTORY_PRINT_Fulo_Filo | `PRINT_FACTORY_PRINT_Fulo_Filo.zsh` | `PRINT_FACTORY_PRINT_Fulo_Filo.shortcut` |
| START_MY_DAY | `START_MY_DAY.zsh` | `START_MY_DAY.shortcut` |
| THINKING_WORKSPACE | `THINKING_WORKSPACE.zsh` | `THINKING_WORKSPACE.shortcut` |

## Fix existing Shortcuts (Hello World stubs)

If `Spencer_DESKTOP_COMMANDER` etc. still show `echo "Hello World"`:

```zsh
zsh scripts/spencer/paste-into-shortcuts.zsh
```

Or Stream Deck → **Spencer → Paste Scripts**. For each layout it copies the Start My Day body and opens the Shortcut — paste with Cmd+A, Cmd+V.

## Stream Deck

Spencer folder buttons run this same pattern via `scripts/spencer/run-layout-shortcut.zsh` (uses the `.zsh` files / CLI). **Start Day** uses your working **Start My Day** Shortcut when available.

## Regenerate

```zsh
python3 scripts/spencer/generate-shortcuts.py
```
