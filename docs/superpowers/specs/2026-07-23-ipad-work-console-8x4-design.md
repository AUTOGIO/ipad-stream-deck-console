# iPad Work Console — 8×4 × 2 Pages

**Date:** 2026-07-23  
**Status:** Approved  
**Scope:** New Stream Deck Mobile profile only — leave existing `iPad Console` for rollback

## Goal

Replace the sparse live Mobile layout with a flat **two-page 8×4** profile (max 64 keys) covering daily work and tools, without nested folders and without Grok / local LLMs.

## Decisions

| Decision | Choice |
|----------|--------|
| Profile name | `iPad Work Console` |
| Grid | 8 columns × 4 rows × 2 pages |
| Layout style | Flat pages (no folders) |
| Page split | A — Work / Tools |
| Excluded | Grok, LM Studio, Ollama, Homebridge, YouTube, JoePrompt leftovers |
| Session ops | Hide apps; never quit on Focus / End Session |
| Current project | `config.json` `active_project` + runtime pointer (JSON, not sourced shell) |
| Session log | Markdown log authoritative; Notes optional later |

## Page 1 — WORK

| Row | Theme | Keys (cols 0–7) |
|-----|--------|-----------------|
| 0 | Launch | START MY DAY · ChatGPT · Atlas · Claude · Codex · Cursor · iTerm · Obsidian |
| 1 | Session | CURRENT PROJECT · FOCUS SESSION · AI STATUS · RESTART AI · END SESSION · Dev Space · Thinking · RESET |
| 2 | Daily apps | Chrome · Gmail · Drive · WhatsApp · Telegram · Gemini · NotebookLM · Desktop Commander (app) |
| 3 | Spencer | Start Day · Cleanup · Commander · NL Layout · Thinking · Fulo Filo · Health · Status |

## Page 2 — TOOLS

| Row | Theme | Keys (cols 0–7) |
|-----|--------|-----------------|
| 0 | Projects | AUTOGIO · Finance · Activity · MacHealth · LifeOS · StreamDeck · Hammerspoon · Pick |
| 1 | Prompts | Explain · Review · Snapshot · Deliver · Compare · Structured · Summary · Quick |
| 2 | Research | Research · Meetings · Finance Ws · Daily Note · Backup · ActivityWatch · Clipboard · HS Guide |
| 3 | System | Finder · Calendar · Mail · Sound · Reload HS · Diag · Act Mon · Verify |

## Architecture

- Config: `config/profiles-ipad-work.json`
- Builder: `scripts/stream-deck/build-profile.py --profile ipad-work`
- New / thin launchers for Chrome, Gmail, Drive (web), WhatsApp, Telegram, NotebookLM (web)
- Session scripts under `scripts/projects/`, `scripts/workspace/`, `scripts/system/` (cloud AI status/restart only)

## Out of scope

- Physical Operations Console redesign
- Re-adding Grok / local LLMs
- Unsaved-document detection / auto-quit
- `sd-ops` dispatcher CLI
