# Repo cleanup prompt

Paste everything below the line into Cursor / Claude / Codex while the messy project is open.

---

You are cleaning up an existing personal project. I am not a developer. Do not redesign features. Do not rewrite the app unless required to move a file safely.

GOAL
Make the repository follow a professional, simple layout and remove clutter.

MANDATORY FOLDER MODEL (use these names; do not invent new top-level folders)
- src/ or app/     → application code (pick whichever already exists; do not create both)
- scripts/         → runnable helpers (.sh, .zsh, .command, Makefile targets’ scripts)
- config/          → settings (non-secret). If both config/ and configs/ exist, merge into config/
- data/            → CSV, Excel, exports, raw inputs (use data/raw, data/processed if helpful)
- assets/          → images, icons, logos (merge duplicate image folders here)
- docs/            → markdown guides, design notes, prompts
- docs/prompts/    → AI prompt files
- tests/           → tests only
- archive/         → obsolete files we are not deleting yet
- Root             → ONLY: README.md, AGENTS.md, .gitignore, and toolchain files
                    (package.json, package-lock.json, vite.config.*, requirements.txt,
                     pyproject.toml, Makefile, docker-compose*.yml, *.code-workspace)

RULES
1. Prefer MOVE over copy. Prefer EDIT existing files over creating new ones.
2. Do not create new top-level folders without asking me first.
3. Remove filename versioning: Foo_v1.0.md → docs/foo.md (put old copy in archive/ if unsure).
4. Merge duplicates (config vs configs; assets vs IMAGES_DEV vs FF_imagens_*).
5. Do not commit secrets. Do not put personal machine inventory into AGENTS.md.
6. Keep Portuguese/English filenames if already used in content, but folder names stay English as above.
7. After moves, fix broken imports/paths if the project would break; tell me what you fixed.
8. Do not delete anything unless it is clearly a duplicate; otherwise move to archive/.

PROCESS
1. Scan the repo root and list misplaced files (grouped by destination folder).
2. Show me a short move plan (from → to). Wait for my OK if anything looks destructive.
3. Execute the moves.
4. Add or update AGENTS.md with the folder rules above (short, durable). Use the same layout rules as a professional personal repo.
5. Add/update .gitignore for: .DS_Store, logs/, tmp/, node_modules/, .env, __pycache__/, .venv/, and other junk appropriate to this stack. Do not gitignore source or needed config.
6. Update README.md with: what the project is, how to run it, and where things live (5–10 lines).
7. Finish with a summary: moved / archived / deleted / still unclear.

If the project type is unclear, ask one question: “Is this mainly a web app, data/analytics, or Mac automation?” Then proceed.
