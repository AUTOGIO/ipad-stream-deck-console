# ACTION-MAP — Stream Deck profiles

## iPad Work Console (Stream Deck Mobile — primary)

**Grid:** 8×4 · **Pages:** 2 · **Config:** `config/profiles-ipad-work.json`  
**Build:** `python3 scripts/stream-deck/build-profile.py --profile ipad-work`  
**Policy:** Cloud LLMs only · no Grok · no folders · Focus hides distractors; End Session closes the START MY DAY apps.

Command details: [`COMMAND-CHEAT-SHEET.md`](COMMAND-CHEAT-SHEET.md)

### Page 1 — WORK

| Row | Keys |
|-----|------|
| 0 Launch | START MY DAY · ChatGPT · Atlas · Claude · Codex · Cursor · iTerm · NOTES |
| 1 Session | CURRENT PROJECT · FOCUS SESSION · AI STATUS · RESTART AI · END SESSION · Dev Space · Thinking · RESET |
| 2 Daily | Chrome · Gmail · Drive · WhatsApp · Telegram · Gemini · NotebookLM · Desktop Commander |
| 3 Spencer | Start Day · Cleanup · Commander · NL Layout · Thinking · Fulo Filo · Health · Status |

### Page 2 — TOOLS

| Row | Keys |
|-----|------|
| 0 Projects | AUTOGIO · Finance · Activity · MacHealth · LifeOS · StreamDeck · Hammerspoon · Pick |
| 1 Prompts | Explain · Review · Snapshot · Deliver · Compare · Structured · Summary · Quick |
| 2 Research | Research · Meetings · Finance Ws · ActivityWatch · Clipboard · HS Guide |
| 3 System | Finder · Calendar · Mail · Sound · Reload HS · Diag · Act Mon · Verify |

### Session ops scripts

| Button | Script |
|--------|--------|
| CURRENT PROJECT | `scripts/projects/open-current-project.zsh` |
| FOCUS SESSION | `scripts/workspace/focus-session.zsh` |
| AI STATUS | `scripts/system/ai-status.zsh` |
| RESTART AI | `scripts/system/restart-ai.zsh` |
| END SESSION | `scripts/workspace/end-session.zsh` — logs the active Cursor project, then quits Cursor, Atlas, Ghostty, and Notes (normal unsaved-work prompts apply). |

---

## Physical Profile: Operations Console (Gate 6 — hybrid 8×8)

### Home Page

| Row | Keys |
|-----|------|
| 1 | START MY DAY · ChatGPT · Atlas · Claude · Codex · Cursor · Terminal · Notes |
| 2 | Dev Space · AI Space · Thinking · Health · RESET · Hammerspoon · Status |
| 3 | AI · Dev · Projects · Research · macOS · System · Prompts · GitHub |

### Folder: AI

| Label | Action |
|-------|--------|
| Gemini | `scripts/launch/open-gemini.zsh` |
| Grok | Browser → grok.com |
| Perplexity | Browser → perplexity.ai |
| ChatGPT | `scripts/launch/open-chatgpt.zsh` |
| Atlas | `scripts/launch/open-chatgpt-atlas.zsh` |
| Codex | `scripts/launch/open-codex.zsh` |
| Term Ops | `hammerspoon://operations?action=launch_terminal_ops` |
| AI Layout | `hammerspoon://operations?action=apply_ai_layout` |

### Folder: Development

| Label | Action |
|-------|--------|
| Ghostty | `scripts/launch/open-ghostty.zsh` — opens at the active Cursor project root. |
| Commit | `scripts/git/commit-push.zsh` |
| Pull | `scripts/git/pull-latest.zsh` |
| Dev Space | `scripts/workspace/development-workspace.zsh` |
| Dev Layout | `hammerspoon://operations?action=apply_coding_layout` |
| Codex | `scripts/launch/open-codex.zsh` |
| Claude | `scripts/launch/open-claude-code.zsh` |
| Console | `hammerspoon://operations?action=apply_dev_console_layout` |

### Folder: Projects

| Label | Action |
|-------|--------|
| AUTOGIO | `scripts/projects/open-project.zsh AI_Engineering_OS` |
| Finance | `scripts/projects/open-project.zsh financas-2026` |
| Activity | `scripts/projects/open-project.zsh WorkflowSuggesterPro` |
| MacHealth | `scripts/projects/open-project.zsh MacHealthOS` |
| LifeOS | `scripts/projects/open-project.zsh PersonalLifeOS` |
| StreamDeck | `scripts/projects/open-project.zsh ipad-stream-deck-console` |
| Hammerspoon | `scripts/projects/open-project.zsh hammerspoon` |
| Pick | `applescript/project-selector.applescript` |

### Folder: Research

| Label | Action |
|-------|--------|
| Research | `scripts/workspace/research-workspace.zsh` |
| Focus | `scripts/workspace/focus-session.zsh` |
| Meetings | `scripts/workspace/meetings-workspace.zsh` |
| Finance | `scripts/workspace/finance.zsh` |
| Notes | `scripts/launch/open-notes.zsh` |
| ActivityWatch | `scripts/launch/open-activitywatch.zsh` |
| Writing | `hammerspoon://operations?action=apply_writing_layout` |

### Folder: macOS

| Label | Action |
|-------|--------|
| Finder | `scripts/launch/open-finder-home.zsh` |
| Calendar | `scripts/launch/open-app-key.zsh calendar` |
| Mail | `scripts/launch/open-app-key.zsh mail` |
| Sound | System Settings |
| Audio | Subfolder → Audio |
| Clipboard | `hammerspoon://guide?action=clipboard` |
| HS Guide | `hammerspoon://operations?action=open_guide` |
| Reload HS | `hammerspoon://operations?action=reload_hammerspoon` |

### Folder: System

| Label | Action |
|-------|--------|
| Health | `scripts/system/health-check.zsh` |
| Status | `scripts/system/status-snapshot.zsh` |
| Refresh | `hammerspoon://operations?action=refresh_status` |
| Verify | `hammerspoon://operations?action=run_verification` |
| Diag | `scripts/system/collect-diagnostics.zsh` |
| Copy Diag | `hammerspoon://operations?action=copy_diagnostics` |
| Activity | `scripts/launch/open-activity-monitor.zsh` |
| Term Ops | `hammerspoon://operations?action=launch_terminal_ops` |

### Folder: Prompts

| Label | Action |
|-------|--------|
| Explain | `hammerspoon://operations?action=ai_prompt&prompt=explain` |
| Review | `hammerspoon://operations?action=ai_prompt&prompt=codex` |
| Snapshot | `hammerspoon://operations?action=ai_prompt&prompt=snapshot` |
| Deliver | `hammerspoon://operations?action=ai_prompt&prompt=deliver` |
| Compare | `hammerspoon://operations?action=ai_prompt&prompt=compare` |
| Structured | `hammerspoon://operations?action=ai_prompt&prompt=structured` |
| Summary | `hammerspoon://operations?action=ai_prompt&prompt=summary` |
| Quick | `hammerspoon://operations?action=ai_prompt&prompt=quick` |

### Folder: Audio (nested under macOS)

| Label | Action |
|-------|--------|
| Sound | System Settings |
| Switcher | AudioSwitcher.app |

## Hammerspoon Layout Actions

| Layout mode | Hammerspoon action |
|-------------|-------------------|
| single_external | `apply_command_center_layout` |
| dual_display | `apply_command_center_layout` |
| single_builtin | `apply_coding_layout` |
| safe_layout | `apply_coding_layout` |

## Rebuild

```zsh
python3 scripts/stream-deck/build-profile.py --profile physical
```
