# AI project templates

Reusable prompts and starter files so Cursor / Claude / Codex keep personal repos tidy.

| File | Use when |
|------|----------|
| [`CLEANUP_PROMPT.md`](CLEANUP_PROMPT.md) | An **old messy** project needs organizing |
| [`AGENTS.template.md`](AGENTS.template.md) | Starting a **new** project (copy to root as `AGENTS.md`) |
| [`MACHINE_PROFILE.example.md`](MACHINE_PROFILE.example.md) | Optional personal Mac notes (paths/apps) — **not** per-repo structure |

## Quick start

### New project

```zsh
cp templates/ai/AGENTS.template.md /path/to/new-project/AGENTS.md
# Optional empty rooms:
mkdir -p /path/to/new-project/{src,scripts,config,data,assets,docs/prompts,tests,archive}
```

### Old messy project

1. Open that project in Cursor / Claude / Codex.
2. Paste the full contents of `CLEANUP_PROMPT.md` as the chat message.
3. Approve the move plan when asked.
4. Leave the generated `AGENTS.md` in that repo.

### Machine profile (optional)

Copy `MACHINE_PROFILE.example.md` once to something like:

`~/Documents/AI/MACHINE_PROFILE.md`

Fill in your paths/apps. Link it from Mac-automation `AGENTS.md` files only when needed. Do **not** put hardware inventories into every project’s `AGENTS.md`.

## Design rules (summary)

- Root stays almost empty.
- One folder per purpose; no parallel names (`config` vs `configs`).
- Structure rules ≠ machine setup (paths live in `config/` or MACHINE_PROFILE).
