# iPad Work Console Implementation Plan

> **For agentic workers:** Implement task-by-task. Steps use checkbox syntax.

**Goal:** Ship Stream Deck Mobile profile `iPad Work Console` — flat 8×4 × 2 pages per approved spec.

**Architecture:** JSON profile source → Python builder emits two keypad pages; thin zsh launchers + session scripts; cloud LLM policy only.

**Tech Stack:** zsh, Python 3, Elgato Stream Deck ProfilesV3, AppleScript hide/notify

## Global Constraints

- Cloud LLMs only (no LM Studio / Ollama / Grok on this profile)
- Hide apps; never quit on Focus / End Session
- Do not replace existing `iPad Console` profile
- Prefer `config.json` / `apps.json` over hardcoded paths

---

### Task 1: Config + apps + launchers

- [ ] Add apps: chrome, gmail, whatsapp, telegram, desktop_commander
- [ ] Add launchers / URL buttons for Drive, NotebookLM, Gemini (existing)
- [ ] Add `focus` / `session` / `ai` / `current_project` blocks to `config.json`

### Task 2: Session-ops scripts (v1)

- [ ] `open-current-project.zsh`, `set-current-project.zsh`
- [ ] `focus-session.zsh` (duration, hide list, log)
- [ ] `ai-status.zsh` (cloud/apps/internet)
- [ ] `restart-ai.zsh` (apps only, confirm, one attempt)
- [ ] `end-session.zsh` (git status, review prompts, log, hide)

### Task 3: Profile JSON + builder

- [ ] Write `config/profiles-ipad-work.json`
- [ ] Extend `build-profile.py` with `--profile ipad-work` (2 flat pages)
- [ ] Build and write `stream-deck/profiles/last-build.json`

### Task 4: Docs + validate

- [ ] Update ACTION-MAP, STATUS, CHANGELOG, validate-config
- [ ] Run `zsh tests/validate-config.zsh`
