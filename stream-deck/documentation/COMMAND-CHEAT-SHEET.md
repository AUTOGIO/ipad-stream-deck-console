# Generated Command Cheat Sheet

The launchers in `stream-deck/generated/commands/` are generated artifacts. Each
one sets `SD_SKIP_DIALOGS=1` and executes the listed source script. Do not edit
them directly; change the source script or profile JSON, then rebuild.

```zsh
python3 scripts/stream-deck/build-profile.py --profile all
```

## Daily workspaces

| Command | What it does | Source script |
|---|---|---|
| `start-my-day.command` | Opens the active project in Cursor, ChatGPT Atlas, Ghostty at that project root, and the native `AUTOGIO/Command Center Inbox` note; applies Command Center. | `scripts/workspace/start-my-day.zsh` |
| `development-workspace.command` | Opens the active project, AI tools, and development layout. | `scripts/workspace/development-workspace.zsh` |
| `ai-engineering.command` | Opens the AI Engineering workspace. | `scripts/workspace/ai-engineering.zsh` |
| `research-workspace.command` | Opens ChatGPT Atlas and Notes; applies Writing layout. | `scripts/workspace/research-workspace.zsh` |
| `finance.command` | Opens the configured spreadsheet, finance folder, and Notes. | `scripts/workspace/finance.zsh` |
| `meetings-workspace.command` | Opens Calendar and mutes the microphone input. | `scripts/workspace/meetings-workspace.zsh` |
| `thinking-workspace.command` | Restores the `THINKING_WORKSPACE` Spencer layout. | `scripts/workspace/thinking-workspace.zsh` |
| `focus-session.command` | Starts a 50-minute Work Focus session, hides configured distractions, logs it, and applies Coding layout. | `scripts/workspace/focus-session.zsh` |
| `end-session.command` | Saves the central journal and project snapshot, then normally closes Cursor, ChatGPT Atlas, Ghostty, and Notes. A plain macOS notification confirms success or asks for attention. | `scripts/workspace/end-session.zsh` |
| `reset-daily-layout.command` | Detects displays, launches required apps, and reapplies the matching layout. | `scripts/workspace/reset-daily-layout.zsh` |

## Projects and Git

| Command | What it does | Source script |
|---|---|---|
| `open-current-project.command` | Opens the active project in Cursor, terminal, and Finder. | `scripts/projects/open-current-project.zsh` |
| `open-project-AI_Engineering_OS.command` | Makes `AI_Engineering_OS` active, opens it in Cursor, and applies Command Center. | `scripts/projects/open-project.zsh AI_Engineering_OS` |
| `open-project-financas-2026.command` | Makes `financas-2026` active, opens it in Cursor, and applies Writing layout. | `scripts/projects/open-project.zsh financas-2026` |
| `open-project-MacHealthOS.command` | Makes `MacHealthOS` active, opens it in Cursor, and applies Coding layout. | `scripts/projects/open-project.zsh MacHealthOS` |
| `open-project-PersonalLifeOS.command` | Makes `PersonalLifeOS` active, opens it in Cursor, and applies Writing layout. | `scripts/projects/open-project.zsh PersonalLifeOS` |
| `open-project-WorkflowSuggesterPro.command` | Makes `WorkflowSuggesterPro` active, opens it in Cursor, and applies Coding layout. | `scripts/projects/open-project.zsh WorkflowSuggesterPro` |
| `open-project-ipad-stream-deck-console.command` | Makes this console active, opens it in Cursor, and applies Dev Console. | `scripts/projects/open-project.zsh ipad-stream-deck-console` |
| `open-project-hammerspoon.command` | Makes `~/.hammerspoon` active, opens it in Cursor, and applies Dev Console. | `scripts/projects/open-project.zsh hammerspoon` |
| `open-project.command` | Requires a project key; the generated command has none and therefore exits with usage help. | `scripts/projects/open-project.zsh` |
| `commit-push.command` | Stages all active-project changes, commits, and pushes. | `scripts/git/commit-push.zsh` |
| `pull-latest.command` | Pulls the active project with rebase and autostash. | `scripts/git/pull-latest.zsh` |

## Apps, links, and native Notes

| Command | What it opens | Source script |
|---|---|---|
| `open-chatgpt.command` | ChatGPT. | `scripts/launch/open-chatgpt.zsh` |
| `open-chatgpt-atlas.command` | ChatGPT Atlas. | `scripts/launch/open-chatgpt-atlas.zsh` |
| `open-claude.command` | Claude. | `scripts/launch/open-claude.zsh` |
| `open-claude-code.command` | The configured Claude Code action; currently Claude desktop. | `scripts/launch/open-claude-code.zsh` |
| `open-codex.command` | A terminal running the configured Codex CLI. | `scripts/launch/open-codex.zsh` |
| `open-cursor.command` | Cursor. | `scripts/launch/open-cursor.zsh` |
| `open-terminal.command` | The configured terminal; currently iTerm. | `scripts/launch/open-terminal.zsh` |
| `open-ghostty.command` | Opens Ghostty at the unambiguous Cursor workspace root; falls back to the saved active project. | `scripts/launch/open-ghostty.zsh` |
| `open-notes.command` | Apple Notes and the persistent `AUTOGIO/Command Center Inbox` note. | `scripts/launch/open-notes.zsh` |
| `open-chrome.command` | Google Chrome. | `scripts/launch/open-chrome.zsh` |
| `open-gmail.command` | Gmail web app. | `scripts/launch/open-gmail.zsh` |
| `open-google-drive.command` | Google Drive in Chrome when available. | `scripts/launch/open-google-drive.zsh` |
| `open-gemini.command` | Gemini in the default browser. | `scripts/launch/open-gemini.zsh` |
| `open-notebooklm.command` | NotebookLM in Chrome when available. | `scripts/launch/open-notebooklm.zsh` |
| `open-whatsapp.command` | WhatsApp. | `scripts/launch/open-whatsapp.zsh` |
| `open-telegram.command` | Telegram. | `scripts/launch/open-telegram.zsh` |
| `open-desktop-commander.command` | Desktop Commander. | `scripts/launch/open-desktop-commander.zsh` |
| `open-activitywatch.command` | ActivityWatch. | `scripts/launch/open-activitywatch.zsh` |
| `open-activity-monitor.command` | macOS Activity Monitor. | `scripts/launch/open-activity-monitor.zsh` |
| `open-app-key-calendar.command` | Calendar. | `scripts/launch/open-app-key.zsh calendar` |
| `open-app-key-mail.command` | Mail. | `scripts/launch/open-app-key.zsh mail` |
| `open-finder-home.command` | Home folder in Finder. | `scripts/launch/open-finder-home.zsh` |
| `open-github-projects.command` | GitHub projects folder in Finder. | `scripts/launch/open-github-projects.zsh` |

## AI prompt tools

These actions use Hammerspoon. Selection-based commands copy a prompt to the
clipboard and open the relevant app or site; they do not submit prompts.

| Command | What it does | Source script |
|---|---|---|
| `ai-prompt-explain.command` | Builds a plain-English explanation prompt from the selected text. | `scripts/hammerspoon/ai-prompt.zsh explain` |
| `ai-prompt-codex.command` | Builds a focused code-review prompt from the selected text. | `scripts/hammerspoon/ai-prompt.zsh codex` |
| `ai-prompt-compare.command` | Builds a comparison prompt and opens ChatGPT, Claude, and Gemini. | `scripts/hammerspoon/ai-prompt.zsh compare` |
| `ai-prompt-structured.command` | Converts selected text into an Objective/Risks/MVP/Roadmap prompt. | `scripts/hammerspoon/ai-prompt.zsh structured` |
| `ai-prompt-summary.command` | Builds a dated Notes summary template from selected text. | `scripts/hammerspoon/ai-prompt.zsh summary` |
| `ai-prompt-snapshot.command` | Creates a dated project snapshot Markdown file. | `scripts/hammerspoon/ai-prompt.zsh snapshot` |
| `ai-prompt-deliver.command` | Opens a selected prompt from `~/Documents/prompts.md` in Claude. | `scripts/hammerspoon/ai-prompt.zsh deliver` |
| `ai-prompt-quick.command` | Opens Hammerspoon's quick-command chooser. | `scripts/hammerspoon/ai-prompt.zsh quick` |

## System and recovery

| Command | What it does | Source script |
|---|---|---|
| `ai-status.command` | Writes and shows cloud-AI workstation readiness. | `scripts/system/ai-status.zsh` |
| `restart-ai.command` | Restarts ChatGPT in non-interactive launcher mode. | `scripts/system/restart-ai.zsh` |
| `health-check.command` | Writes a read-only system health report. | `scripts/system/health-check.zsh` |
| `status-snapshot.command` | Shows the Hammerspoon operations health snapshot. | `scripts/system/status-snapshot.zsh` |
| `collect-diagnostics.command` | Collects a reviewed diagnostics archive. | `scripts/system/collect-diagnostics.zsh` |

## Spencer layouts

Every command below restores the named Spencer layout with its saved apps. The
`START_MY_DAY` variant first uses an Apple Shortcut named **Start My Day**, when
it exists.

| Command | Layout |
|---|---|
| `run-layout-shortcut-CLEANUP.command` | `CLEANUP` |
| `run-layout-shortcut-DESKTOP_COMMANDER.command` | `DESKTOP_COMMANDER` |
| `run-layout-shortcut-NOTEBOOKLM.command` | `NOTEBOOKLM` |
| `run-layout-shortcut-PRINT_FACTORY_PRINT_Fulo_Filo.command` | `PRINT_FACTORY_PRINT_Fulo_Filo` |
| `run-layout-shortcut-START_MY_DAY.command` | `START_MY_DAY` |
| `run-layout-shortcut-THINKING_WORKSPACE.command` | `THINKING_WORKSPACE` |

## Safety notes

- `commit-push.command` stages **all** active-project changes before committing.
- Generated commands skip dialogs. Do not use them for irreversible actions
  unless the source script is explicitly safe in non-interactive mode.
- The generated directory contains 63 current launchers after the 2026-07-25
  rebuild. Rebuilds may change this inventory.
