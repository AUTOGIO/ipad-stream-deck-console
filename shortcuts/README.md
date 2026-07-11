# Shortcuts Wrappers (Optional)

Stream Deck can call zsh scripts directly. Apple Shortcuts wrappers are optional.

## Why Optional

- Shell scripts work via Stream Deck **Open** action
- Shortcuts add an extra layer without clear benefit for simple launches
- Existing shortcuts (`HEALTH_CHECK`, etc.) are left unchanged to avoid conflicts

## Creating SD-Prefixed Shortcuts (Manual)

If Open-on-script fails, create shortcuts in the Shortcuts app:

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

### SD-CollectDiagnostics

Same pattern with:

```zsh
zsh /Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console/scripts/system/collect-diagnostics.zsh
```

### SD-ProjectSelector

Add action: **Run AppleScript**

```applescript
run script POSIX file "/Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console/applescript/project-selector.applescript"
```

## Stream Deck Integration

Use the **Shortcuts** plugin (if installed) or export shortcuts and point Stream Deck **Open** at the `.shortcut` file in:

```
~/Library/Shortcuts/
```

## CLI Testing

```zsh
shortcuts run "SD-HealthCheck"
```

(Only works after creating the shortcut manually.)
