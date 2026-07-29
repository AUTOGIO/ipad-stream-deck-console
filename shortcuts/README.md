# Shortcuts

Stream Deck can call zsh scripts directly. Apple Shortcuts are used where they add a reliable control path (especially Spencer layouts).

## Spencer desktop layouts

Matches the **Start My Day** Shortcut pattern: open Spencer → wait for CLI → `spencer --restore "<LAYOUT>" --launch-apps=true`.

| Layout | Shortcut name | Stream Deck |
|--------|---------------|-------------|
| `CLEANUP` | `Spencer CLEANUP` | Spencer → Cleanup |
| `DESKTOP_COMMANDER` | `Spencer DESKTOP_COMMANDER` | Spencer → Desktop |
| `NOTEBOOKLM` | `Spencer NOTEBOOKLM` | Spencer → NotebookLM |
| `PRINT_FACTORY_PRINT_Fulo_Filo` | `Spencer PRINT_FACTORY` | Spencer → Print Factory |
| `START_MY_DAY` | `Start My Day` (existing) | Spencer → Start Day |
| `THINKING_WORKSPACE` | `Spencer THINKING_WORKSPACE` | Spencer → Thinking / home Thinking |

### Install

```zsh
zsh scripts/spencer/install-shortcuts.zsh
```

This generates signed `.shortcut` files under `shortcuts/spencer/` and opens them. Click **Add Shortcut** for each prompt. Reuse your existing **Start My Day** shortcut for `START_MY_DAY`.

### Manual create (same as Start My Day)

1. Open **Shortcuts** → New Shortcut  
2. Name it e.g. `Spencer CLEANUP`  
3. Add **Run Shell Script** (zsh), paste:

```zsh
open -a Spencer
for i in {1..20}; do
  if /Applications/Spencer.app/Contents/MacOS/SpencerCLI --list >/dev/null 2>&1; then
    /Applications/Spencer.app/Contents/MacOS/SpencerCLI --restore "CLEANUP" --launch-apps=true
    exit $?
  fi
  sleep 0.5
done
echo "Spencer CLI did not become ready" >&2
exit 1
```

4. Save

### CLI test

```zsh
shortcuts run "Start My Day"
shortcuts run "Spencer THINKING_WORKSPACE"
# or fallback path used by Stream Deck:
SD_SKIP_DIALOGS=1 zsh scripts/spencer/run-layout-shortcut.zsh THINKING_WORKSPACE
```

If a Shortcut is missing, Stream Deck still restores via Spencer CLI so buttons keep working.

## Optional SD wrappers

If Open-on-script fails for other actions, create shortcuts named `SD-HealthCheck`, etc. See older notes below.

### SD-HealthCheck

1. Open **Shortcuts** app  
2. New Shortcut → name: `SD-HealthCheck`  
3. Add action: **Run Shell Script**  
4. Shell: `/bin/zsh`  
5. Script:

```zsh
export SD_SKIP_DIALOGS=0
zsh /Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console/scripts/system/health-check.zsh
```

6. Save
