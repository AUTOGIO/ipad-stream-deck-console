# TESTING

## Automated tests

| Test | Command |
|------|---------|
| Config validation | `zsh tests/validate-config.zsh` |
| Launchers | `zsh tests/test-launchers.zsh` |
| Health check | `zsh tests/test-health-check.zsh` |
| Layout scripts | `zsh tests/test-layout-scripts.zsh` |
| Start My Day | `SD_SKIP_DIALOGS=1 zsh tests/test-start-my-day.zsh` |

## MVP test matrix (manual)

| Action | Expected | Status |
|--------|----------|--------|
| Start My Day | ≤6 apps, layout applied, notification | |
| Start My Day (repeat) | Blocked while lock active | |
| Reset Daily Layout | Windows repositioned, no relaunch storm | |
| Stream Deck login | Single login item, app starts after login | |
| Health Check | Report in `reports/` | |
| Shutdown Workspace | Confirmed quit of workspace apps only | |

Set `SD_SKIP_DIALOGS=1` for non-interactive script runs.

## Display scenarios

- Ultrawide only → `single_external`
- Built-in only → `single_builtin`
- Both → `dual_display`
- Unknown → `safe_layout`
