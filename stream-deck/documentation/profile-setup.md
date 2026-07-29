# Manual Profile Setup Guide

Primary Mobile profile: **iPad Work Console** (8×4 · 2 pages). Legacy **iPad Console** is rollback-only.

## 1. Create Profile (automated — recommended)

```zsh
cd ~/Documents/GitHub/ipad-stream-deck-console
zsh stream-deck/documentation/backup-stream-deck-config.zsh
python3 scripts/stream-deck/build-profile.py --profile ipad-work
```

This quits Stream Deck, writes **iPad Work Console**, and relaunches the app.

Physical / hybrid:

```zsh
python3 scripts/stream-deck/build-profile.py --profile physical
```

Legacy Mobile folder layout (rollback):

```zsh
python3 scripts/stream-deck/build-profile.py --profile mobile
```

**Manual alternative (legacy iPad Console only):**

1. Open **Elgato Stream Deck**
2. Click profile dropdown → **Add Profile**
3. Name: `iPad Console` (rollback) or use builder for Work Console

## 2. Select profile after build

- Stream Deck Mobile → **iPad Work Console**
- Physical deck → **Operations Console**

Canonical button inventory: [ACTION-MAP.md](ACTION-MAP.md).

## 3. Wire buttons

Prefer Open → generated `.command` launchers under `stream-deck/generated/commands/` (rebuilt by the profile builder). Do not wire `stream-deck/generated copy/` (removed).

Use absolute paths under the project root when wiring manually. See [button-wiring.md](button-wiring.md).
