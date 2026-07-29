# iPad Pairing Checklist

## Mac Steps (Agent / User)

- [x] Install **Elgato Stream Deck** for macOS from [Elgato Downloads](https://www.elgato.com/downloads) (filter: Stream Deck → mac)
- [x] Launch Stream Deck on Mac
- [x] Grant **Local Network** permission when macOS prompts
- [ ] If firewall blocks pairing: System Settings → Network → Firewall → Options → allow Stream Deck
- [x] Create or import the **iPad Work Console** profile (`python3 scripts/stream-deck/build-profile.py --profile ipad-work`)
- [x] Wire all buttons via profile builder
- [x] Prune duplicate profile entries if menu shows repeated names (`python3 scripts/stream-deck/prune-duplicate-profiles.py`)
- [ ] Test one button from Mac Stream Deck app first

Legacy rollback only: `python3 scripts/stream-deck/build-profile.py --profile mobile` builds **iPad Console** (folder layout).

## iPad Steps (User Only)

- [ ] Install **Stream Deck Mobile** from the App Store
- [ ] Connect iPad to the **same Wi-Fi** as the Mac
- [ ] Open Stream Deck Mobile
- [ ] Tap **Connect** and select your Mac
- [ ] Confirm pairing code matches on both devices
- [ ] Select the **iPad Work Console** profile (pages **WORK** + **TOOLS**)
- [ ] Test one button (e.g. START MY DAY, Cursor, or Health Check)

## Reconnection Tests

After initial pairing, verify recovery from:

| Scenario | Expected |
|----------|----------|
| Mac restart | iPad reconnects within ~30s |
| iPad app restart | Profile reloads, buttons work |
| Wi-Fi interruption | Reconnects when network returns |
| Stream Deck quit/relaunch | iPad shows Mac as available again |

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Mac not listed on iPad | Same Wi-Fi, Stream Deck running on Mac |
| Pairing fails | Disable VPN, check firewall |
| Buttons visible but no action | Test script in Terminal; check execute permission |
| Wrong app opens | Update `defaults` in `config/apps.json` |

## Verification Status

- Stream Deck macOS: **Installed** (v7.5.0) — listening on port 28198
- Primary Mobile profile: **iPad Work Console** (`config/profiles-ipad-work.json`)
- Legacy **iPad Console**: keep for rollback only
- iPad pairing: confirm WORK/TOOLS pages after selecting Work Console
