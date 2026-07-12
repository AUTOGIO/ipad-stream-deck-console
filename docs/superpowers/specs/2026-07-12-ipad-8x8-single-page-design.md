# iPad Console — Single 8×8 Page Design

**Date:** 2026-07-12  
**Status:** Approved  
**Scope:** Stream Deck Mobile (iPad) only — no physical console

## Goal

Replace the nested-folder iPad Console with one flat **8×8** page of themed row zones, using the rich Operations Console action set, without LM Studio or Ollama.

## Decisions

| Decision | Choice |
|----------|--------|
| Layout style | Themed zones on one page (row bands) |
| Device | iPad / Stream Deck Mobile only |
| Button set | Rich set (from Operations Console actions) |
| Zone arrangement | One theme per row |
| Excluded | LM Studio, Ollama, nested folders, physical deck redesign |
| Deferred | Shutdown key (spare slots on AI/Dev rows) |

## Row map

| Row | Zone | Keys (cols 0–7) |
|-----|------|-----------------|
| 0 | Launch | START MY DAY · ChatGPT · Atlas · Claude · Codex · Cursor · Terminal · Obsidian |
| 1 | AI | Gemini · Grok · Perplexity · Models · AI Space · AI Layout · Term Ops · *(empty)* |
| 2 | Projects | AUTOGIO · Finance · Activity · MacHealth · LifeOS · StreamDeck · Hammerspoon · Pick |
| 3 | Dev | Dev Space · Commit · Pull · Dev Layout · Console · GitHub · *(empty)* · *(empty)* |
| 4 | Prompts | Explain · Review · Snapshot · Deliver · Compare · Structured · Summary · Quick |
| 5 | Research | Research · Focus · Meetings · Finance Ws · Daily Note · Backup · Writing · ActivityWatch |
| 6 | macOS | Finder · Calendar · Mail · Sound · Switcher · Clipboard · HS Guide · Reload HS |
| 7 | System | Health · Status · Refresh · Verify · Diag · Copy Diag · Act Mon · RESET |

**Fill:** 59 actions · 5 empty cells.

## Architecture

### Config

- Add `config/profiles-ipad.json` as the mobile source of truth:
  - `grid: { "columns": 8, "rows": 8 }`
  - Flat `home_page` array with `col`, `row`, `label`, and action fields (`script`, `args`, `hammerspoon`, `url`, `path`, `path_key`, `app_key`, `applescript`, `guide` as used today in `profiles-physical.json`)
  - No `folders` object for the active mobile layout
- Wire each button to the same scripts / Hammerspoon actions already used by the Operations Console map (see `stream-deck/documentation/ACTION-MAP.md`), excluding LM Studio and Ollama.

### Builder

- Update `scripts/stream-deck/build-profile.py`:
  - `build_ipad_layout()` reads `profiles-ipad.json` and emits **one** page with positions `col,row` for `0..7 × 0..7`
  - No folder page manifests, no Back keys on the main page
  - Keep writing both mobile targets already used: `iPad Console` and `iPad Console (Surface)`
- Default operational path: `--profile mobile`
- Physical profile build may remain in the script but is out of scope for this change and should not be required for day-to-day use

### Documentation

- Update ACTION-MAP, STATUS, profile-setup, and related pairing docs to describe the single 8×8 iPad page
- Stop presenting physical Operations Console as a required user path

## Verification

1. `tests/validate-config.zsh` passes with `profiles-ipad.json`
2. `python3 scripts/stream-deck/build-profile.py --profile mobile` succeeds with `page_count: 1`
3. In Stream Deck macOS app, Mobile profile shows an 8×8 keypad
4. On iPad: spot-check one key per row (Launch → System)
5. Prompt keys still invoke Hammerspoon / `scripts/hammerspoon/ai-prompt.zsh`

## Out of scope

- Physical Operations Console redesign or removal from the repo
- Re-adding LM Studio / Ollama
- New icon packs or marketplace plugins
- Adding Shutdown unless requested later

## Success criteria

- iPad Stream Deck shows one page, 8×8, with the row-band layout above
- No folder navigation required for any key on the approved map
- Existing launchers, project openers, git, workspace, and prompt scripts keep working
