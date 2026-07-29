# Repository Audit Report

**Repository:** `ipad-stream-deck-console`  
**Audit date:** 2026-07-29  
**Mode:** Read-only (only this report file created)  
**Auditor role:** Evidence-based repository audit per repository-audit skill

---

## 1. Executive Summary

This repository is a **single-user macOS control-plane** that turns Stream Deck Mobile (iPad) and/or a physical Stream Deck into thin buttons that run zsh/Python/AppleScript workflows on one Mac. The **working tree is operationally rich** (session ops, layout detection, profile builder, Notes-based Command Center) and **config validation passed on this machine**, but **Git does not represent the live system**.

The tracked tree is still approximately the early MVP (~47 files, July 2026). Most production scripts, `config/config.json`, profile sources (`profiles-ipad-work.json`, `profiles-physical.json`), and Stream Deck builder code exist only as **untracked or modified** files. A fresh clone of `master` cannot run the system described in `STATUS.md` / `AGENTS.md`.

Highest priorities: **preserve and commit (or otherwise backup) the working system**, **make `config.json` cloneable via a template**, and **harden the Stream Deck git commit/push button** before further feature work.

No committed API keys, passwords, or private keys were found. Primary risks are **operational reproducibility**, **destructive automation on the active project**, **config/doc drift**, and **local disk bloat from full Stream Deck backups**.

---

## 2. Audit Scope and Limitations

**In scope**

- Repository structure, config, scripts, tests, Stream Deck docs/profiles metadata
- Safe local validation (`validate-config`, health-check test, display/layout detection, tool versions)
- Security pattern search (secrets, dangerous shell, hardcoded paths)
- Architecture, documentation vs implementation, hygiene

**Out of scope / not executed**

- Remediation or commits
- Package installs / dependency updates
- Profile rebuild (`build-profile.py` quits/relaunches Stream Deck)
- `tests/test-launchers.zsh` and `tests/test-start-my-day.zsh` (open apps / rearrange workspace)
- Live iPad pairing verification
- Hammerspoon config outside this repo (`~/.hammerspoon`)
- Inspection of binary Elgato backups beyond size/path evidence

**Blocked / unverified**

- End-to-end Mobile button press → script on device
- Whether ChatGPT’s bundle ID `com.openai.codex` is correct on this Mac beyond “path exists”
- Behavior of Spencer Shortcuts on a clean Shortcuts install

---

## 3. Initial Repository State

| Item | Value |
|------|--------|
| Root | `/Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console` |
| Branch | `master` @ `79bbfe7` |
| Remote | **None configured** (`git remote -v` empty) |
| Submodules | None |
| Worktrees | Single worktree |
| Disk size | **~1.2G** total; **`backups/` ~895M**, **`reports/` ~281M** |
| Status | Large dirty tree: ~81 short-status lines (modified + deleted + untracked) |
| Nested repos | None under root (only `./.git`) |

**Recent commits (tracked history only)**

1. `79bbfe7` docs: add iPad 8x8 single-page console design spec  
2. `56897c4` feat: add iPad Stream Deck console MVP  

**Ignored / generated (relevant)**

- `.gitignore` ignores `logs/*`, `reports/*`, `backups/*`, `stream-deck/generated/`, profile exports
- Does **not** ignore `stream-deck/generated copy/`, `.cursor/`, `.memory/`, or `config/config.json`

**Snapshot implication:** the machine’s live console is mostly **outside** the last committed snapshot.

---

## 4. Repository Purpose

| Aspect | Assessment | Basis |
|--------|------------|--------|
| **Intended purpose** | Mac workflow control surface via Stream Deck Mobile / physical deck | `README.md`, `AGENTS.md`, `STATUS.md` |
| **Likely user** | Single operator (hardcoded home paths for `eduardofgiovannini`) | `config/paths.json`, `config/config.json` |
| **Primary workflows** | Start My Day, Focus Session, End Session, app launchers, project open, health/diagnostics, profile build | `scripts/workspace/*`, `scripts/launch/*`, `scripts/stream-deck/build-profile.py` |
| **Inputs** | Button presses → Open `.command` / app / `hammerspoon://` / Shortcuts | `AGENTS.md`, builder |
| **Outputs** | Apps launched, layouts applied, session journal, health/diagnostic reports, Elgato profiles | Runtime dirs + `reports/` |
| **Persistent data** | `~/Library/Application Support/AUTOGIO/streamdeck/`, logs under AUTOGIO, session log under `~/Reports/WorkSessions` | `config.json` paths |
| **External services** | Cloud LLM apps (ChatGPT/Atlas/Claude/etc.), Elgato Stream Deck, Wi‑Fi for Mobile | Policy in `STATUS.md` / `AGENTS.md` |
| **Local services** | Hammerspoon, Stream Deck app, optional ActivityWatch, optional LaunchAgent | Scripts + INSTALLATION |
| **Deployment model** | Local clone at fixed path; profile builder writes into Elgato Application Support | INSTALLATION, builder |

**Documented vs implemented**

| Claim | Status |
|-------|--------|
| Thin buttons; logic in repo scripts | **Implemented** (builder emits Open → `.command`) |
| Cloud LLMs only (no LM Studio/Ollama) | **Mostly implemented** in active scripts/config; **stale** in tracked deleted files + `generated copy` |
| Primary Mobile profile = iPad Work Console 8×4×2 | **Implemented** in working tree / STATUS; **docs/README still describe legacy folders** |
| `config.json` is required init source of truth | **Implemented** (`sd_init_from_script`); **not in Git** |
| Focus never quits apps | **Docs conflict**: CHANGELOG 2026-07-23 vs 2026-07-25; config `session.quit_apps: true` for End Session |

---

## 5. Repository Map

| Path | Purpose |
|------|---------|
| `config/` | `apps.json`, `paths.json`, `config.json` (runtime), `profiles*.json` (button metadata) |
| `scripts/lib/` | Shared init, logging, app detection, locks, Hammerspoon helpers |
| `scripts/launch/` | Thin app/path/URL openers |
| `scripts/workspace/` | Multi-app day/session/layout flows |
| `scripts/system/` | Health, diagnostics, displays, AI status/restart, Stream Deck ensure |
| `scripts/projects/` | Active project pointer / open by key |
| `scripts/stream-deck/` | Profile builder, login item helpers, prune |
| `scripts/git/` | Commit+push / pull against active project |
| `scripts/hammerspoon/` | Bridge wrappers |
| `scripts/spencer/` | Shortcut generation/install/layout helpers |
| `applescript/` | Project picker |
| `layouts/` | Display-scenario JSON for layout selection |
| `stream-deck/documentation/` | Install, wiring, ACTION-MAP, rollback, tests |
| `stream-deck/generated/` | Generated launchers (gitignored) |
| `stream-deck/generated copy/` | **Abandoned duplicate** of generated launchers (not ignored) |
| `stream-deck/profiles/` | Last-build metadata |
| `shortcuts/spencer/` | Spencer shortcut assets |
| `tests/` | Config validation + smoke tests |
| `docs/superpowers/` | Design specs/plans |
| `templates/ai/` | Reusable AGENTS/cleanup templates for other repos |
| `reports/` | Generated health/diagnostics/session artifacts (gitignored content) |
| `backups/` | Local Elgato config dumps (gitignored content; very large) |
| `AGENTS.md` / `STATUS.md` | Agent orientation / live ops status |

**Entry points:** Stream Deck Open actions → `stream-deck/generated/commands/*.command` → `scripts/**/*.zsh`; also `python3 scripts/stream-deck/build-profile.py`.

---

## 6. Technology Stack

| Technology | Evidence |
|------------|----------|
| zsh (`set -euo pipefail` on most scripts) | `scripts/**/*.zsh` |
| Python 3 (stdlib only; no `requirements.txt`) | `build-profile.py`, JSON helpers |
| AppleScript / `osascript` | Dialogs, quit/hide, login items, project selector |
| Swift (standalone watcher) | `scripts/system/reports-file-alert.swift` |
| Hammerspoon URL scheme | `sd_invoke_hammerspoon`, profile URLs |
| Elgato Stream Deck macOS 7.5+ | STATUS, INSTALLATION |
| Apple Shortcuts (optional Focus) | `focus-session.zsh` |
| macOS Apple Silicon assumed | README, AGENTS |
| Git (used by session/git buttons) | `scripts/git/*`, `end-session.zsh` |
| No Node/npm app, no Docker, no CI workflows | Absence of `package.json`, `.github/`, Dockerfile |

**Observed tool versions (this host):** zsh 5.9; Python 3.14.6; Swift 6.4; git 2.55.0; arm64 darwin.

---

## 7. Architecture Overview

```
iPad / Physical Stream Deck
        ↓
Elgato Stream Deck (macOS)
        ↓
Thin Open / hammerspoon:// / Shortcut
        ↓
Generated .command → scripts/*.zsh
        ↓
scripts/lib/common.zsh (init, config, logging)
        ↓
Apps / Finder / git / Hammerspoon layouts / reports
```

**Actual characteristics**

- **Config-driven** personal automation, not a networked service
- **Multiple profile product lines** in one repo: legacy Mobile folders, iPad Work Console, physical Operations Console
- **Shared library** pattern is sound; most launchers correctly call `sd_init_from_script` in-process
- **Hidden global state:** `active_project` file under Application Support; locks under `~/.autogio/streamdeck/`
- **Duplicate abstractions:** `apps.json` catalog vs `config.json` `applications`; `paths.json` vs `config.json` `paths`
- **Ambition–Capacity Mismatch:** feature surface (Spencer layouts, three profile configs, git-from-button, FSEvents Documents watcher, duplicate generated trees) exceeds what Git currently preserves and what a single-operator console needs for day-to-day reliability

---

## 8. Build, Test, and Run Procedure

### Canonical prepare (documented + evidenced)

1. Place repo at `~/Documents/GitHub/ipad-stream-deck-console` (README hardcodes absolute path).
2. Ensure `config/config.json`, `apps.json`, `paths.json` exist (`sd_init_from_script` exits 2 if missing).
3. `chmod +x scripts/**/*.zsh tests/*.zsh`
4. `zsh tests/validate-config.zsh`
5. Install Elgato Stream Deck + Hammerspoon; pair iPad (same Wi‑Fi).
6. Backup then build:  
   `zsh stream-deck/documentation/backup-stream-deck-config.zsh`  
   `python3 scripts/stream-deck/build-profile.py --profile ipad-work` (or `physical` / `all`)
7. Select correct profile in Elgato UI (STATUS: **iPad Work Console** on Mobile).

### Test commands (documented)

```zsh
zsh tests/validate-config.zsh
export SD_SKIP_DIALOGS=1
zsh tests/test-launchers.zsh          # opens apps — skipped in this audit
zsh tests/test-health-check.zsh
zsh tests/test-layout-scripts.zsh     # applies layout via Hammerspoon — partially skipped
zsh tests/test-start-my-day.zsh       # opens apps — skipped
```

### Start / stop

- Not a long-running server. “Start” = Stream Deck + Hammerspoon running; optional login item via `configure-streamdeck-login.zsh`.
- Optional persistent watcher: `reports-file-alert.swift` (if launched separately).
- “Stop” = quit Stream Deck / Hammerspoon; End Session may quit configured work apps.

### Recovery

- Profile rollback: `stream-deck/documentation/ROLLBACK.md` (includes destructive wipe of Elgato Application Support — use carefully).
- Backups under `backups/` (local).
- Lock cleanup for Start My Day: remove `~/.autogio/streamdeck/start-my-day.lock` if stale.

### Conflicts in procedure

| Source | Says | Conflict |
|--------|------|----------|
| `STATUS.md` / ACTION-MAP | Primary Mobile = **iPad Work Console**; build `--profile ipad-work` | |
| `INSTALLATION.md` / pairing checklist / README inventory | Select / build **iPad Console** (legacy) | Stale primary profile guidance |
| README button table | Legacy folder MVP set | Omits session ops / Work Console |
| CHANGELOG 2026-07-23 | End Session never quit | CHANGELOG 2026-07-25 + `session.quit_apps: true` quit apps |

---

## 9. Commands Executed

| Command | Exit | Result |
|---------|------|--------|
| `pwd` / `git status` / `git branch` / `git remote -v` / `git log -10` / `git submodule status` / `du -sh` | 0 | State captured; no remote; ~1.2G |
| Structure `find` (depth-limited) | 0 | Map built |
| Secret / dangerous-pattern `rg` scans | 0 | No credential material found; risky patterns noted |
| `zsh --version` / `python3 --version` / `swift --version` / `git --version` | 0 | Toolchain present |
| `git diff --check` | 0 | Trailing whitespace in AppleScript + shortcuts README |
| `zsh tests/validate-config.zsh` | 0 | 71 checks, 0 errors, 1 warning (missing legacy `profiles-ipad.json`) |
| `zsh tests/test-health-check.zsh` | 0 | **Passed, but asserted oldest report** (see AUDIT-009) |
| `zsh scripts/system/detect-displays.zsh` | 0 | `single_external` |
| `zsh scripts/system/select-layout.zsh` | 0 | `layouts/single-external.json` |
| `python3 scripts/stream-deck/build-profile.py --help` | 0 | Profiles: mobile, physical, ipad-work, all |

**Skipped (side effects):** `test-launchers.zsh`, `test-start-my-day.zsh`, full `test-layout-scripts.zsh` (Hammerspoon layout apply), `build-profile.py` without `--help`, backup script, End Session.

---

## 10. Findings Summary

| ID | Severity | Priority | Category | Finding | Confidence |
|---|---|---|---|---|---|
| AUDIT-001 | High | P0 | Repository hygiene | Live system not preserved in Git; tracked tree is stale MVP | Confirmed |
| AUDIT-002 | High | P0 | Reliability | `config.json` required at runtime but untracked; clone cannot init | Confirmed |
| AUDIT-003 | High | P1 | Security | Stream Deck commit-push runs `git add -A` + `push` on active project | Confirmed |
| AUDIT-004 | Medium | P1 | Correctness | Diagnostics copies config using undefined `${root}` | Confirmed |
| AUDIT-005 | Medium | P1 | Architecture | Multiple path/app sources of truth (`apps.json` vs `config.json`, divergent `logs_dir`) | Confirmed |
| AUDIT-006 | Medium | P1 | Documentation | Primary profile / inventory docs lag STATUS & Work Console | Confirmed |
| AUDIT-007 | Medium | P2 | Repository hygiene | Abandoned `stream-deck/generated copy/` with dead LM Studio/Ollama/focus-mode launchers | Confirmed |
| AUDIT-008 | Medium | P2 | Reliability | Full Elgato tree backups (~179M each) + hardcoded project root in backup script | Confirmed |
| AUDIT-009 | Medium | P2 | Testing | Health-check test validates oldest report, not the one just produced | Confirmed |
| AUDIT-010 | Medium | P2 | Repository hygiene | No git remote configured | Confirmed |
| AUDIT-011 | Medium | P2 | Correctness | `pull-latest.zsh` runs `pull --rebase --autostash` with no confirmation | Confirmed |
| AUDIT-012 | Medium | P2 | Reliability | Documents-wide FSEvents notifier (`reports-file-alert.swift`) | High confidence |
| AUDIT-013 | Medium | P2 | Architecture | Ambition–capacity mismatch (multi-profile + Spencer + uncommitted surface) | High confidence |
| AUDIT-014 | Low | P3 | Reliability | Lock files without atomic `flock` (TOCTOU) | Confirmed |
| AUDIT-015 | Low | P3 | Repository hygiene | `.gitignore` gaps (`.cursor/`, `.memory/`, `generated copy`) | Confirmed |
| AUDIT-016 | Low | P3 | Documentation | CHANGELOG Focus/End Session quit policy contradicts itself and config | Confirmed |
| AUDIT-017 | Low | P3 | Reliability | Leftover empty diagnostics staging dirs under `reports/` | Confirmed |
| AUDIT-018 | Informational | P3 | macOS | Pervasive hardcoded `/Users/eduardofgiovannini` (personal-machine design) | Confirmed |
| AUDIT-019 | Informational | P3 | Dependency | No package manifests/lockfiles (stdlib-only Python — acceptable) | Confirmed |
| AUDIT-020 | Informational | P3 | Testing | No CI; launcher/start-my-day tests are side-effecting smoke tests | Confirmed |
| AUDIT-021 | Informational | P3 | Correctness | ChatGPT `bundle_id` = `com.openai.codex` (verify vs Classic `com.openai.chat`) | Needs verification |

---

## 11. Critical Findings

None confirmed. No credential compromise, no automatic wipe of user data without an explicit button/script path, and no remote exploit surface in this repo’s code.

---

## 12. High Findings

### [AUDIT-001] Live working tree not represented in Git

- Severity: High
- Priority: P0
- Confidence: Confirmed
- Category: Repository hygiene
- File: repository root (Git index vs working tree)
- Location: `git ls-files` (~47 tracked) vs ~58 working `scripts/**/*.zsh`; untracked `config/config.json`, `profiles-ipad-work.json`, `build-profile.py`, etc.
- Evidence:
  - Tracked history ends at MVP + design doc commits.
  - Working tree includes the Operations/Work Console system described in `STATUS.md` / `CHANGELOG.md` but mostly as `??` / modified files.
  - Tracked still lists deleted `scripts/launch/open-lm-studio.zsh` and `open-obsidian-ai.zsh`.
- Impact:
  - Machine loss, accidental clean, or clone elsewhere loses the operational console.
  - “Git is the source of truth” is false for this project today.
- Recommendation:
  - After backup, stage and commit the intentional working system (or export a dated archive), excluding `backups/`, large `reports/`, and secrets.
- Validation:
  - Fresh clone (or worktree) runs `zsh tests/validate-config.zsh` and lists the same critical scripts as `STATUS.md`.

### [AUDIT-002] Required `config/config.json` is untracked

- Severity: High
- Priority: P0
- Confidence: Confirmed
- Category: Reliability
- File: `config/config.json`, `scripts/lib/common.zsh`
- Location: `sd_init_from_script` requires `config.json` or `exit 2`
- Evidence:
  - `git ls-files config/` → only `apps.json`, `paths.json`, `profiles.json`.
  - Init: `sd_require_file "config.json" "$SD_CONFIG_JSON" || exit 2`.
- Impact:
  - Fresh checkout cannot run any script that initializes shared libs.
- Recommendation:
  - Add `config/config.example.json` (with `$HOME`-relative guidance) and document copy-to-`config.json`; keep machine-specific values local **or** commit a sanitized default if this remains a single-machine repo.
- Validation:
  - Clone without private config → follow docs → validate-config passes.

### [AUDIT-003] Commit-and-push button stages everything and pushes

- Severity: High
- Priority: P1
- Confidence: Confirmed
- Category: Security
- File: `scripts/git/commit-push.zsh`
- Location: lines 14–31
- Evidence:
  - Operates on `sd_get_active_project`.
  - `/usr/bin/git … add -A` then `commit` then `push`.
  - With `SD_SKIP_DIALOGS=1`, message defaults to `chore: stream deck update` with no review of file list.
- Impact:
  - One Stream Deck press can commit secrets, large binaries, or unrelated WIP in **any** active project and push to its remote.
- Recommendation:
  - Require explicit file selection or `git status` confirmation dialog; never `add -A` silently; block when `.env`/credential patterns present; make push opt-in.
- Validation:
  - Dry-run test project: button must not stage unlisted files; push disabled unless confirmed.

---

## 13. Medium Findings

### [AUDIT-004] Diagnostics archive omits project config due to undefined `root`

- Severity: Medium
- Priority: P1
- Confidence: Confirmed
- Category: Correctness
- File: `scripts/system/collect-diagnostics.zsh`
- Location: lines 47–49 (`${root}/config/...` with `|| true`)
- Evidence:
  - Init sets `SD_ROOT`, not `root`.
  - Failures are swallowed, so archives lack intended config copies.
- Impact:
  - Diagnostics incomplete when troubleshooting.
- Recommendation:
  - Replace `${root}` with `${SD_ROOT}`; fail loudly if copy fails.
- Validation:
  - Run diagnostics with `SD_SKIP_DIALOGS=1` and confirm `apps.json`/`paths.json` inside the zip.

### [AUDIT-005] Multiple configuration sources of truth

- Severity: Medium
- Priority: P1
- Confidence: Confirmed
- Category: Architecture
- File: `config/apps.json`, `config/config.json`, `config/paths.json`
- Location: parallel `applications`/`apps` and `paths` blocks
- Evidence:
  - `config.json` `paths.logs_dir` → `~/Library/Logs/AUTOGIO/StreamDeck`
  - `paths.json` `logs_dir` → repo `logs/`
  - Health/diagnostics use `sd_load_path` (paths.json); init logging prefers config when set.
- Impact:
  - Scripts read different log locations; app catalogs can diverge.
- Recommendation:
  - Single read path: prefer `config.json` with `paths.json` as thin legacy shim, or generate one from the other.
- Validation:
  - Grep shows one canonical getter used by launch, health, and diagnostics for logs/reports.

### [AUDIT-006] Documentation still centers legacy iPad Console

- Severity: Medium
- Priority: P1
- Confidence: Confirmed
- Category: Documentation
- File: `README.md`, `stream-deck/documentation/INSTALLATION.md`, `ipad-pairing-checklist.md`, `profile-setup.md`
- Location: profile selection / inventory sections
- Evidence:
  - STATUS/ACTION-MAP: primary = **iPad Work Console**.
  - INSTALLATION step 6: select **iPad Console**.
  - README folder inventory ≠ Work Console pages.
- Impact:
  - Operators/agents wire or select the wrong profile after rebuild.
- Recommendation:
  - Align README + INSTALLATION + pairing checklist with STATUS; mark legacy profile as rollback-only.
- Validation:
  - Docs only name Work Console as default Mobile profile.

### [AUDIT-007] Abandoned `stream-deck/generated copy/` with dead targets

- Severity: Medium
- Priority: P2
- Confidence: Confirmed
- Category: Repository hygiene
- File: `stream-deck/generated copy/`
- Location: e.g. `commands/open-lm-studio.command`, `open-ollama.command`, `focus-mode.command`, `shutdown-workspace.command`
- Evidence:
  - Directory not gitignored; ~396K.
  - Targets scripts that are deleted/missing (`open-lm-studio.zsh`, `focus-mode.zsh`, etc.).
  - CHANGELOG notes Focus Mode / Shutdown removed.
- Impact:
  - Confusion; risk of wiring Stream Deck to dead launchers if copied manually.
- Recommendation:
  - Delete or archive outside the repo; ensure only `stream-deck/generated/` (gitignored, rebuilt) is used.
- Validation:
  - No `generated copy` path references in docs or builder.

### [AUDIT-008] Oversized Stream Deck backups and hardcoded backup root

- Severity: Medium
- Priority: P2
- Confidence: Confirmed
- Category: Reliability
- File: `stream-deck/documentation/backup-stream-deck-config.zsh`
- Location: lines 8–24; `backups/stream-deck_*` (~179M each, multiple copies)
- Evidence:
  - `PROJECT_ROOT="/Users/eduardofgiovannini/Documents/GitHub/ipad-stream-deck-console"`
  - `cp -R` entire Application Support tree including bundled `NodeJS/.../node` (~85M per backup).
- Impact:
  - Disk fill; backup script fails if repo moved; backups harder to manage.
- Recommendation:
  - Resolve project root from script location; exclude `NodeJS` or back up only Profiles/Preferences; prune old backups.
- Validation:
  - New backup size ≪ current ~179M; works from relocated clone.

### [AUDIT-009] Health-check test asserts the wrong report file

- Severity: Medium
- Priority: P2
- Confidence: Confirmed
- Category: Testing
- File: `tests/test-health-check.zsh`
- Location: lines 14–19 (`reports[1]` after alphabetical glob)
- Evidence:
  - On this host, `reports[1]` = `health-check_2026-07-11_...`; newest = `2026-07-29_...`.
  - Test still PASSed after generating a new report.
- Impact:
  - Regressions in newly written report content can go undetected.
- Recommendation:
  - Capture path from script output or select latest by mtime (`reports[-1]` after sort, or `ls -t`).
- Validation:
  - Delete old reports or inject a bad old file; test must fail if new report is wrong.

### [AUDIT-010] No git remote

- Severity: Medium
- Priority: P2
- Confidence: Confirmed
- Category: Repository hygiene
- File: N/A (Git configuration)
- Location: `git remote -v` empty
- Evidence:
  - No `origin`; commit-push from this repo cannot push itself; off-machine backup relies solely on local disk.
- Impact:
  - No offsite recovery for this control-plane repo.
- Recommendation:
  - Add a private remote when ready; do not push `backups/` or secret-bearing config.
- Validation:
  - `git remote -v` shows origin; push of intentional commits succeeds.

### [AUDIT-011] Unconfirmed rebase pull from Stream Deck

- Severity: Medium
- Priority: P2
- Confidence: Confirmed
- Category: Correctness
- File: `scripts/git/pull-latest.zsh`
- Location: line 14 `git pull --rebase --autostash`
- Evidence:
  - No dialog; acts on whatever `sd_get_active_project` returns.
- Impact:
  - Unexpected rebase/autostash on the wrong repo from a mis-set active project.
- Recommendation:
  - Confirm project path + branch in UI; avoid autostash unless explicitly opted in.
- Validation:
  - Cancel path leaves repo untouched; confirm path shows basename before pull.

### [AUDIT-012] Broad filesystem watcher on `~/Documents`

- Severity: Medium
- Priority: P2
- Confidence: High confidence
- Category: Reliability
- File: `scripts/system/reports-file-alert.swift`
- Location: `watchedRoots` includes `/Users/.../Documents` and `/Users/.../Reports`
- Evidence:
  - STATUS documents notifications for every new/changed file under those trees.
  - Hardcoded absolute user paths.
- Impact:
  - Notification noise; privacy surface if logs of paths are retained; CPU cost on large Documents trees.
- Recommendation:
  - Narrow roots to `~/Reports` (and optional allowlist); read paths from config; document how the watcher is started/stopped.
- Validation:
  - Saving unrelated Documents files does not notify; Reports saves still do.

### [AUDIT-013] Ambition–capacity mismatch

- Severity: Medium
- Priority: P2
- Confidence: High confidence
- Category: Architecture
- File: multiple (profiles, spencer, generated copy, untracked scripts)
- Location: product surface vs Git + single-operator capacity
- Evidence:
  - Three profile JSON models + Spencer shortcut pipeline + Documents watcher + git buttons, while Git still holds MVP.
- Impact:
  - Maintenance and doc drift; higher chance of wiring dead paths.
- Recommendation:
  - Freeze profile variants: keep Work Console + one physical profile; defer Spencer/legacy Mobile unless actively used; commit the frozen subset.
- Validation:
  - Documented “supported surface” ≤ committed scripts/tests.

---

## 14. Low and Informational Findings

### [AUDIT-014] Non-atomic lock files

- Severity: Low
- Priority: P3
- Confidence: Confirmed
- Category: Reliability
- File: `scripts/lib/common.zsh`
- Location: `sd_acquire_lock` / `sd_release_lock`
- Evidence:
  - Check-then-write lock file without `mkdir`-based atomic lock or `flock`.
- Impact:
  - Rare double Start My Day on concurrent presses.
- Recommendation:
  - Use `mkdir` lock dir or `flock`.
- Validation:
  - Parallel invocations: second exits with lock message.

### [AUDIT-015] `.gitignore` incomplete for local tooling leftovers

- Severity: Low
- Priority: P3
- Confidence: Confirmed
- Category: Repository hygiene
- File: `.gitignore`
- Location: entire file
- Evidence:
  - `stream-deck/generated/` ignored; `generated copy/` not; `.cursor/`, `.memory/` not ignored.
- Impact:
  - Accidental staging of editor/debug noise.
- Recommendation:
  - Extend ignore list; delete obsolete copy directory.
- Validation:
  - `git status` does not list those paths after ignore update.

### [AUDIT-016] CHANGELOG quit-policy contradiction

- Severity: Low
- Priority: P3
- Confidence: Confirmed
- Category: Documentation
- File: `CHANGELOG.md`, `config/config.json`
- Location: 2026-07-23 “never quit” vs 2026-07-25 quit four apps; `session.quit_apps: true`
- Evidence:
  - Conflicting entries; End Session implements quit when flag true.
- Impact:
  - Agents may follow wrong policy (AGENTS still says treat End Session as destructive — that part is correct).
- Recommendation:
  - Amend CHANGELOG note clarifying supersession.
- Validation:
  - Single stated End Session app policy matches config.

### [AUDIT-017] Leftover diagnostics staging directories

- Severity: Low
- Priority: P3
- Confidence: Confirmed
- Category: Reliability
- File: `reports/.diagnostics_staging_*`
- Location: eight empty dirs observed
- Evidence:
  - Trap cleanup should remove staging; empty dirs remain from older runs / interrupted flows.
- Impact:
  - Clutter only (currently empty).
- Recommendation:
  - Periodic cleanup; ensure trap always runs.
- Validation:
  - No stale staging dirs after successful diagnostics.

### [AUDIT-018] Hardcoded user home paths (by design)

- Severity: Informational
- Priority: P3
- Confidence: Confirmed
- Category: macOS
- File: `config/paths.json`, `config/config.json`, `applescript/project-selector.applescript`, backup script, Swift watcher
- Location: `/Users/eduardofgiovannini/...`
- Evidence:
  - Widespread absolute paths in tracked `paths.json` and AppleScript.
- Impact:
  - Non-portable by design; acceptable for single-machine ownership if documented.
- Recommendation:
  - Prefer `"${HOME}/..."` in scripts; keep machine profile in untracked or example config.
- Validation:
  - Scripts resolve via `$HOME` or config expansion.

### [AUDIT-019] No third-party dependency manifests

- Severity: Informational
- Priority: P3
- Confidence: Confirmed
- Category: Dependency
- File: N/A
- Location: repo root
- Evidence:
  - No `requirements.txt` / `package.json`; Python uses stdlib.
- Impact:
  - None for supply chain in-repo; relies on system Python 3 / zsh / Swift toolchain.
- Recommendation:
  - Keep stdlib-only; optionally document minimum Python 3.x.
- Validation:
  - Builder `--help` on clean macOS with Xcode CLT / python3.

### [AUDIT-020] Tests are local smoke tests without CI

- Severity: Informational
- Priority: P3
- Confidence: Confirmed
- Category: Testing
- File: `tests/*`
- Location: suite
- Evidence:
  - No `.github/workflows`; launcher tests open real apps.
- Impact:
  - Regressions only caught when run manually on this Mac.
- Recommendation:
  - Keep non-interactive config/layout unit checks; gate app-opening tests behind an env flag.
- Validation:
  - Document which tests are safe for automation.

### [AUDIT-021] ChatGPT bundle ID equals Codex ID

- Severity: Informational
- Priority: P3
- Confidence: Needs verification
- Category: Correctness
- File: `config/apps.json`
- Location: `apps.chatgpt.bundle_id` = `com.openai.codex`; Classic uses `com.openai.chat`
- Evidence:
  - Validate-config PASSed because `/Applications/ChatGPT.app` exists (path short-circuit in `sd_app_installed`).
- Impact:
  - Bundle-ID fallback open may target wrong app if path missing.
- Recommendation:
  - Verify with `mdls -name kMDItemCFBundleIdentifier /Applications/ChatGPT.app`.
- Validation:
  - Bundle ID matches installed ChatGPT; Codex has its own entry if distinct.

---

## 15. Security Assessment

**Overall:** Low remote attack surface (local automation). Highest practical risk is **privileged local automation** (git push, app quit, Elgato profile rewrite) triggered by physical/iPad buttons.

| Area | Result |
|------|--------|
| Committed secrets | None found (pattern scan) |
| `.env` / keys in repo | Not present |
| `sudo` / `curl \| sh` | Not found in scripts |
| Subprocess usage | Controlled (`open`, `osascript`, `git`, `subprocess.run` with arg lists in Python) |
| Shell injection | Dialog text JSON-escaped via Python; some AppleScript interpolations use trusted config names |
| Supply chain | Stdlib Python; Elgato backups contain vendored Node binaries (local only) |
| Diagnostics | Intentionally excludes secrets; copies machine paths (username exposure in archives) |

Treat AUDIT-003 as the main security remediation.

---

## 16. Correctness Assessment

Strengths: consistent `set -euo pipefail` on action scripts; in-process `sd_init_from_script`; Start My Day lock+trap; End Session project detection is careful about multi-window ambiguity.

Material correctness issues: AUDIT-004 (diagnostics root), AUDIT-005 (path divergence), AUDIT-009 (test oracle), AUDIT-011 (unconfirmed pull), possible AUDIT-021 (bundle ID).

---

## 17. Reliability and Operational Stability

**On this machine:** validate-config succeeds; display detection works; health check produces reports; last-build metadata shows iPad Work Console was built into Elgato ProfilesV3.

**Risks:** Git unreproducible (AUDIT-001/002); disk pressure from backups (AUDIT-008); notification spam (AUDIT-012); lock TOCTOU (AUDIT-014); profile builder quits Stream Deck (expected but disruptive); stale locks possible if process killed before EXIT trap.

Logging: dual destinations possible (`paths.json` vs AUTOGIO) — operators may look in the wrong place.

---

## 18. Architecture and Complexity Assessment

Core layering (thin button → script → config → OS) is appropriate.

**Simplify / defer**

- Legacy Mobile folder profile as rollback-only (stop documenting as primary)
- Delete `stream-deck/generated copy/`
- Spencer shortcut factory unless actively used daily
- Documents-wide file watcher → Reports-only
- Git commit/push from deck → opt-in advanced folder, not primary WORK page

**Ambition–Capacity Mismatch:** confirmed (AUDIT-013). Prefer freezing and committing the Command Center + Work Console slice over adding profiles.

---

## 19. Dependency Assessment

No npm/pip lockfiles. Runtime depends on:

- macOS + zsh + python3 + osascript
- Elgato Stream Deck.app
- Hammerspoon (layouts)
- User-installed apps listed in `apps.json`

This is appropriate. No unused package managers to prune. Supply-chain risk is dominated by Elgato’s own bundled Node inside backups, not by this repo’s code.

---

## 20. Testing Assessment

| Suite | Role | Notes |
|-------|------|-------|
| `validate-config.zsh` | Strong gate | Passed here |
| `test-health-check.zsh` | Report sections | Oracle bug AUDIT-009 |
| `test-layout-scripts.zsh` | Display + layout | Side effects (Hammerspoon) |
| `test-launchers.zsh` | Opens apps | Incomplete vs full launcher set |
| `test-start-my-day.zsh` | Smoke | Opens apps; weak assertions |

Untested critical paths: End Session quit behavior, commit-push, profile builder, diagnostics zip contents, Focus Shortcuts fallback.

---

## 21. Documentation Assessment

| Doc | Quality vs code |
|-----|-----------------|
| `AGENTS.md` | Strong durable policy; aligns with working architecture |
| `STATUS.md` | Best live ops truth |
| `ACTION-MAP.md` | Primary inventory for buttons |
| `README.md` | Stale inventory/profile story |
| `INSTALLATION.md` / pairing | Legacy profile names |
| `ROLLBACK.md` | Useful; destructive steps need care |
| `CHANGELOG.md` | Useful history; internal contradiction on quit policy |

Treat STATUS + ACTION-MAP + AGENTS as authoritative over README until README is updated.

---

## 22. macOS and Apple-Specific Assessment

- Apple Silicon / arm64 confirmed on audit host.
- Heavy use of Automation (System Events), Login Items, Shortcuts, Hammerspoon URL scheme — requires TCC permissions (expected).
- Hardcoded `/Users/eduardofgiovannini` throughout (AUDIT-018).
- Login item helper and optional LaunchAgent are reasonable; LaunchAgent writes logs under configured logs dir.
- Profile builder mutates `~/Library/Application Support/com.elgato.StreamDeck` and Preferences via PlistBuddy — backup-first discipline is mandatory and documented.

---

## 23. Shell Script Assessment

**Positives:** shebang + strict mode on most entry scripts; PATH bootstrap for Stream Deck launches; quoting generally careful; destructive diagnostics gated by dialog (unless `SD_SKIP_DIALOGS=1`).

**Weak spots:** undefined `root` in diagnostics; `commit-push` / `pull-latest` power; backup hardcoded root; spencer scripts without `set -euo pipefail` (libraries also omit strict mode by design when sourced); `rm -rf` only on mktemp staging (acceptable with trap).

---

## 24. Repository Hygiene

| Issue | Detail |
|-------|--------|
| Dirty tree | Majority of real system uncommitted |
| Size | 1.2G dominated by ignored backups/reports |
| Duplicate generated | `generated copy/` |
| Tracked obsolete | LM Studio / Obsidian launchers still in index as deleted |
| Ignore gaps | `.cursor`, `.memory`, generated copy |
| Remote | None |
| Fresh clone | Not operational without untracked files |

A fresh clone of current `master` is **not** sufficient to run the console described in STATUS.

---

## 25. Prioritized Remediation Plan

### Stage 0 — Preserve and Validate

1. Full Time Machine / disk backup of repo + `~/Library/Application Support/com.elgato.StreamDeck`.
2. Run `zsh stream-deck/documentation/backup-stream-deck-config.zsh` once more if disk allows (or slim backup after AUDIT-008 fix).
3. Re-run `zsh tests/validate-config.zsh`.
4. **Do not** run commit-push from Stream Deck until AUDIT-003 fixed.

**Validation:** backups exist; validate-config exit 0.  
**Rollback:** restore Elgato from `backups/`.  
**Do not attempt yet:** profile rebuild without backup; force-push; deleting Elgato Application Support.

### Stage 1 — Critical Stabilization

1. Commit or archive the working system (AUDIT-001) excluding backups/reports/secrets.
2. Add `config.example.json` / document config bootstrap (AUDIT-002).
3. Harden `commit-push.zsh` (AUDIT-003).
4. Fix diagnostics `${SD_ROOT}` (AUDIT-004).

**Validation:** clean clone path documented; commit-push cannot `add -A` blindly; diagnostics zip contains config.  
**Dependencies:** Stage 0 backup first.  
**Rollback:** revert commits; restore config from example.

### Stage 2 — Reliability Improvements

1. Unify logs/paths SoT (AUDIT-005).
2. Slim backups + dynamic project root (AUDIT-008).
3. Fix health-check test oracle (AUDIT-009).
4. Confirm/gate `pull-latest` (AUDIT-011).
5. Narrow file watcher roots (AUDIT-012).

### Stage 3 — Simplification

1. Remove `generated copy/` (AUDIT-007).
2. Declare legacy iPad Console rollback-only; update docs (AUDIT-006, AUDIT-013).
3. Defer Spencer automation unless proven weekly-use.
4. Add private remote (AUDIT-010) after hygiene cleanup.

### Stage 4 — Maintainability

1. Expand `.gitignore` (AUDIT-015).
2. Resolve CHANGELOG policy (AUDIT-016).
3. Atomic locks (AUDIT-014).
4. Verify ChatGPT bundle ID (AUDIT-021).
5. Optional: non-side-effecting unit tests for JSON resolution / lock helpers.

---

## 26. Quick Wins

1. Fix `${root}` → `${SD_ROOT}` in `collect-diagnostics.zsh`.
2. Delete or move aside `stream-deck/generated copy/`.
3. Point INSTALLATION Mobile profile line to **iPad Work Console**.
4. Fix health-check test to use newest report.
5. Add `.cursor/` and `.memory/` to `.gitignore`.
6. Add one-line warning at top of `commit-push.zsh` until redesigned (or disable button in profile JSON).
7. Document “no git remote yet” in STATUS.
8. Prune oldest oversized Stream Deck backups after confirming one good restore candidate.
9. Correct CHANGELOG End Session quit note.
10. Verify ChatGPT bundle ID with `mdls` and record in apps.json comment/STATUS.

---

## 27. Deferred Improvements

- CI for `validate-config` on macOS runners
- `$HOME`-relative path templating for multi-machine use
- Automated Elgato profile diff/tests without quitting the app
- Spencer shortcut codegen consolidation
- Full Disk Access / TCC entitlement documentation pack
- Replacing personal absolute paths in tracked `paths.json` with examples

---

## 28. Unresolved Questions

1. Is there an intentional private remote not configured in this worktree?
2. Is `stream-deck/generated copy/` retained on purpose for rollback comparison?
3. Is the Documents FSEvents watcher launched at login, and where is that LaunchAgent defined (if any)?
4. Should `config.json` remain machine-private forever, or is a sanitized committed default acceptable?
5. Is ChatGPT.app’s bundle ID intentionally `com.openai.codex` on this install?

---

## 29. Final Recommendation

**Stabilize before expanding.** The console on this Mac appears usable (config validates; Work Console was built), but **version control does not protect that usability**. Next action: **preserve the working tree (backup + intentional commit/archive), add a cloneable config template, and disable or harden the git commit-push action.** Defer new profiles, Spencer work, and watcher scope until the committed repository can reproduce Start My Day + Work Console without relying on untracked files.

**Do not begin broad refactors or rewrites.** Prefer the incremental stages above.

---

*End of audit report. Application source and configuration were not modified during this audit; only `REPOSITORY_AUDIT.md` was created.*
