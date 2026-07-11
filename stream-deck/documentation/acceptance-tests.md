# GATE 5 Acceptance Test Plan

Run after Stream Deck macOS is installed and iPad is paired.

## Prerequisites

- [ ] Elgato Stream Deck installed from [Elgato Downloads](https://www.elgato.com/downloads) (Stream Deck → macOS)
- [ ] Stream Deck Mobile on iPad from [App Store](https://apps.apple.com/app/stream-deck-mobile/id1476615877)
- [ ] iPad and Mac on same Wi-Fi
- [ ] All scripts executable (`chmod +x scripts/**/*.zsh`)
- [ ] `tests/validate-config.zsh` passes with 0 errors

## A. Script Tests (Mac Terminal)

| Test | Command | Expected |
|------|---------|----------|
| Config valid | `zsh tests/validate-config.zsh` | Exit 0, 0 errors |
| Launchers | `SD_SKIP_DIALOGS=1 zsh tests/test-launchers.zsh` | 10/10 pass |
| Health check | `SD_SKIP_DIALOGS=1 zsh tests/test-health-check.zsh` | Report created |
| Project selector | `osascript applescript/project-selector.applescript` | Dialog appears, cancel works |
| AI workspace | `SD_SKIP_DIALOGS=1 zsh scripts/workspace/ai-engineering.zsh` | Apps launch |
| Finance workspace | `SD_SKIP_DIALOGS=1 zsh scripts/workspace/finance.zsh` | Apps + folder open |
| Diagnostics preview | `SD_SKIP_DIALOGS=1 zsh scripts/system/collect-diagnostics.zsh` | Manifest shown, cancel OK |

## B. Stream Deck Profile Tests (Mac)

| Test | Steps | Expected |
|------|-------|----------|
| Profile exists | Open Stream Deck → iPad Console profile | 6 folders + Safety visible |
| Single button | Press Cursor button | Cursor opens |
| Shell script button | Press Health Check | Report in Finder |
| AppleScript button | Press Pick Project | Project list dialog |
| Repeated press | Press Cursor 3× quickly | No harmful duplicates |

## C. iPad Tests (User)

| Test | Steps | Expected |
|------|-------|----------|
| Connection | Open Stream Deck Mobile | Mac listed and connected |
| Profile sync | Select iPad Console | Same buttons as Mac |
| Remote press | Tap Cursor on iPad | Cursor opens on Mac |
| 10+ actions | Test 10 different buttons | ≥10 work correctly |
| Reconnect Mac restart | Restart Mac, reopen Stream Deck | iPad reconnects |
| Reconnect iPad restart | Force-quit iPad app, reopen | Profile reloads |
| Wi-Fi blip | Toggle Wi-Fi off/on | Reconnects within 60s |

## D. Acceptance Criteria

Implementation is **accepted** when:

- [x] Project directory and config exist
- [x] All 15 action scripts exist
- [x] Health check produces report
- [x] Project selector works
- [x] Both workspace launchers work
- [ ] iPad connects to Stream Deck on Mac *(user step)*
- [ ] Profile loads with all buttons visible *(user step)*
- [ ] ≥10 actions work from iPad *(user step)*

## E. Recording Results

Update `STATUS.md` with:

- Date tested
- Pass/fail per action
- iPad pairing verified: yes/no
- Notes on firewall or beta macOS issues

## Download Links

| Product | URL |
|---------|-----|
| Elgato Stream Deck (macOS) | https://www.elgato.com/downloads |
| Stream Deck Mobile (iPad) | https://apps.apple.com/app/stream-deck-mobile/id1476615877 |
| Elgato downloads (PT) | https://www.elgato.com/lm/pt/s/downloads |

## iPad Development Context

This project uses iPad as a **control surface only** (Stream Deck Mobile), not as a code execution environment. For iPad-as-workstation context see:

- [Apple iPadOS Get Started](https://developer.apple.com/ipados/get-started/)
- [Apple iPadOS Resources](https://developer.apple.com/ipados/resources/)
- [WWDC25 Session 208](https://developer.apple.com/videos/play/wwdc2025/208/)

The Mac remains the execution host for all workflows.
