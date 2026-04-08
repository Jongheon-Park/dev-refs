# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] — 2026-04-08

### Added
- `docs/examples/subagents/` — Path B subagent examples (`planner`, `coder`,
  `tester`) for users who prefer model-isolated dispatch over slash commands.
  Opt-in: copy to `.claude/agents/` to enable `@planner`, `@coder`, `@tester`.
- `setup.sh --update` mode — refresh kit-owned files (`.claude/CLAUDE.md`,
  `discovery.md`, `agents/`, `commands/`, `settings.json`) in an existing
  project without re-running initial setup. User-owned files are never touched.
- `docs/ai-docs/_trash/.gitkeep` — preserve protected directory in git
- `VERSION` file (1.3.0)
- `CHANGELOG.md` (this file)
- README "Advanced — Path B (Subagent Dispatch)" section pointing to examples
- README "Update dev-refs" section documenting the `--update` workflow

### Changed
- **Phase labels**: `CMD 1/2/3 — Planner/Coder/Tester` → `Phase 1/2/3 — Plan/Code/Test`
  in all skill descriptions and inline references. Aligns with single-CMD
  workflow (`/plan → /clear → /implement → /clear → /test`).
- README — "Three-CMD Workflow" replaced with "Single-Conversation Workflow":
  one conversation, three phases, `/clear` between phases, document chain
  carries state. Adds optional `/model` cost-optimization recipe (Opus for
  Phase 1, Sonnet for Phase 2/3). Tree refreshed (adds `agents/`,
  `docs/examples/`, `VERSION`, `CHANGELOG.md`). Document Production Map
  relabeled CMD→Phase. README grew 371→435 lines.
- `docs/profiles/README.md` rewritten — directory now ships empty, profiles
  created on demand by Discovery
- `docs/ai-docs/_index.md` placeholder examples — generic instead of
  C++/MFC/OpenCV-specific
- `skills/chat-over-session.md` example — `[CMD 1]/[CMD 2]` → `[Session A]/[Session B]`

### Removed
- `docs/_legacy/` — 9 historical AI rule files (~80 KB). Discovery's legacy
  detection still works against user-project legacy files; the kit no longer
  ships its own historical rules.
- `docs/profiles/cpp-mfc.md`, `cpp-imgui.md`, `cpp-opencv.md` — language-biased
  profiles. Discovery auto-creates new ones per detected stack.
- README "## docs/_legacy/" section

### Fixed
- (carried from previous unpushed work) Deterministic `_status.md` auto-load
  via SessionStart hook

### Upgrading from V1.2

For each project linked to dev-refs:

```bash
# 1. Pull the latest kit
cd /path/to/dev-refs && git pull

# 2. Refresh kit-owned files in each project
bash /path/to/dev-refs/setup.sh <project-root> --update
```

The `--update` mode (new in V1.3) refreshes:
- `.claude/CLAUDE.md`, `.claude/discovery.md` (rules)
- `.claude/agents/` (subagent definitions)
- `.claude/commands/` (slash command skills)
- `.claude/settings.json` (SessionStart hook — installed if missing)

User-owned files are **never touched**: project `CLAUDE.md`, `docs/profiles/`,
`docs/ai-docs/`.

**Optional cleanup of pre-V1.3 artifacts** in each project:

```bash
rm -rf <project-root>/docs/_legacy/
rm <project-root>/docs/profiles/cpp-*.md
```

These are no longer shipped by the kit and can be safely removed unless your
project actively references them.

**If you use Path B (subagent dispatch)**, copy the new examples once:

```bash
cp /path/to/dev-refs/docs/examples/subagents/*.md <project-root>/.claude/agents/
```

This adds `@planner`, `@coder`, `@tester` for model-isolated phase dispatch.
The default Path A (slash commands `/plan`, `/implement`, `/test`) requires
no extra setup.

**No code or ticket migration needed.** The CMD→Phase rename is purely a label
change in skill descriptions; existing tickets, reports, `_memory.md`, and
`_status.md` files work unchanged.

## Previous versions

See `git log --oneline` for full history. Major prior releases:

- **V1.2** — Session state system (`_status.md`, SessionStart hook), file
  protection, subagent verification, strict tester role boundaries
- **V1.1** — 3-CMD workflow with 10 skills, recording system, verifier
- **V1.0** — Initial Claude Code project rules kit
