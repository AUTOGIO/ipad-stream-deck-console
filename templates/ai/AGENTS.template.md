# AGENTS.md

Personal project. Owner is not a professional developer; keep the repo simple and tidy.

## Layout (mandatory)

| Path | Purpose |
|------|---------|
| `src/` or `app/` | Application code only (one of these, not both) |
| `scripts/` | Helper commands and automation |
| `config/` | Non-secret settings |
| `data/` | Datasets, CSV, Excel, exports |
| `assets/` | Images, icons, static media |
| `docs/` | Human docs and design notes |
| `docs/prompts/` | Saved AI prompts |
| `tests/` | Tests |
| `archive/` | Obsolete files (do not use as a junk drawer forever) |

**Root may contain only:** `README.md`, `AGENTS.md`, `.gitignore`, and toolchain/entrypoint files
(`package.json`, lockfiles, `vite.config.*`, `requirements.txt`, `Makefile`, compose files, workspace file).

## Rules for AI assistants

1. Do not create new top-level folders without asking.
2. Do not leave docs, CSVs, images, or prompts in the project root.
3. Prefer editing existing files over adding new ones.
4. Prefer replacing outdated files over keeping `_v1`, `_old`, `_backup`, or dated copies in-tree. Use Git history or `archive/`.
5. One name per concept: never add a parallel folder (`config` vs `configs`, `assets` vs `images`).
6. After structural changes, update README if run instructions changed.
7. Do not put hardware specs, full app inventories, or absolute `/Users/...` paths in this file. Those belong in `config/` when the project needs them.

## When machine-specific paths are required

Store them in `config/` (e.g. `config/paths.json`). Read from config in code/scripts; do not hardcode the same path in many files.

If a personal machine profile exists (e.g. `~/Documents/AI/MACHINE_PROFILE.md`), read it only when the task needs Mac paths or installed apps.

## Definition of done for any task

- Root still clean
- New files in the correct folder
- No duplicate “same purpose” folders created
- Short note in the reply: what was added/changed and where
