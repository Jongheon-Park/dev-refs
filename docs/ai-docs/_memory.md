# Session Memory

<!-- Updated at session end or after significant work.
     Read at session start for cross-session context.
     Keep concise — prune entries older than ~5 sessions. -->

## Recent Work

<!-- What was done recently. Newest first. Format: YYMMDD: summary -->

- **260409**: V1.3 fully folded into single commit + tag. Phase B (setup.sh --update + README rewrite) and Step 4 (CHANGELOG "Upgrading from V1.2" migration section) both amended into v1.3.0. Tag re-applied at final amended commit. Push still pending user OK.
- **260408**: V1.3 release work in two phases (both now committed under e9d5d2d after 260409 amend).
  - **Phase A**: Removed `docs/_legacy/` (9 files, ~80 KB) + `docs/profiles/cpp-*.md` (3 files). Renamed `CMD 1/2/3` → `Phase 1/2/3` across all 10 skill files. Added `docs/examples/subagents/` as opt-in Path B reference (planner, coder, tester + README) — agents/ restored to original {architect, reviewer, explorer}. Added VERSION (1.3.0), CHANGELOG.md. Updated README "Advanced — Path B" section. profiles/README.md rewritten — directory ships empty.
  - **Phase B**: Added `setup.sh --update` mode (~107 lines, full lifecycle tested). Rewrote README — tree (added agents/, docs/examples/, VERSION, CHANGELOG), Update section (--update mode usage), Skills headings (CMD→Phase), Three-CMD Workflow → Single-Conversation Workflow with /clear flow + /model cost optimization, mermaid blocks, Document Production Map, Last Updated date. README 371→435 lines.
- **260408 prior**: profiles slimming (cpp-* removal), _legacy/ removal, _trash/.gitkeep added — these are now part of V1.3 commit.

## Pending

<!-- Work in progress or blocked items. Remove when resolved. -->

- Push: `git push origin main && git push origin v1.3.0` (awaits user OK)
- Manual: `rm docs/ai-docs/_trash/rules.md.bak` (15 KB, untracked, Claude policy forbids _trash deletion)

## Workspace Reference

<!-- Key paths, package names, frequently accessed files. -->

- `VERSION` (1.3.0), `CHANGELOG.md` — root, new in V1.3
- `agents/` — {architect, reviewer, explorer} (3, original setup)
- `docs/examples/subagents/` — Path B opt-in (planner, coder, tester + README)
- `setup.sh` — supports `--update` mode for refreshing kit-owned files
- 2 commits ahead of origin/main: 465a1cb (V1.2.x fix) + e9d5d2d (V1.3, amended 260409)
- Untracked (intentionally excluded from V1.3): `.claude/settings.local.json`, `docs/ai-docs/_trash/rules.md.bak`, `docs/ai-docs/tickets/idea/260327-feat-pre-commit-hook.md`, `docs/ppt/`

## Ephemeral Notes

<!-- Temporary observations that may expire. Delete when no longer relevant. -->

- LF→CRLF git warnings on Windows for newly created files — harmless, git handles via core.autocrlf
- README is for humans (not auto-loaded by Claude) — line count not constrained by 200 rule
- Auto-loaded files combined: 226 lines (CLAUDE.md 57 + rules.md 155 + _status.md 14) — within reasonable bounds
