# iPad Pairing Checklist

## Mac Steps (Agent / User)

- [ ] Install **Elgato Stream Deck** for macOS from [Elgato Downloads](https://www.elgato.com/downloads) (filter: Stream Deck → mac)
- [ ] Alternative regional page: [Elgato Downloads PT](https://www.elgato.com/lm/pt/s/downloads)
- [ ] Launch Stream Deck on Mac
- [ ] Grant **Local Network** permission when macOS prompts
- [ ] If firewall blocks pairing: System Settings → Network → Firewall → Options → allow Stream Deck
- [ ] Create or import the **iPad Console** profile (see `button-wiring.md`)
- [ ] Wire all 15 buttons to scripts/apps
- [ ] Test one button from Mac Stream Deck app first

## iPad Steps (User Only)

- [ ] Install **Stream Deck Mobile** from the App Store
- [ ] Connect iPad to the **same Wi-Fi** as the Mac (`192.168.0.x` network)
- [ ] Open Stream Deck Mobile
- [ ] Tap **Connect** and select your Mac (Eduardo's MacBook Air)
- [ ] Confirm pairing code matches on both devices
- [ ] Select the **iPad Console** profile
- [ ] Test one button (e.g. Cursor or Health Check)

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

- Stream Deck macOS: **Not installed** (as of project creation)
- iPad pairing: **Not verified** — complete this checklist at GATE 5
