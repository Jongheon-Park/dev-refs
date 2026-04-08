# Rules — Claude Code Universal Rules

<!-- Symlinked into projects as .claude/CLAUDE.md. Edit here → all projects update. -->

## System File Registry

All rule-system files. Any update must be checked against ALL files for consistency.

```
0.Rules/
├── rules.md              # Universal rules (this file)
├── _status.md            # Session state template
├── discovery.md          # Project discovery (on-demand)
├── agents/               # Subagent definitions (explorer, reviewer, architect)
├── skills/               # Slash commands (/plan, /implement, /test, etc.)
└── docs/ai-docs/         # Per-project AI docs, tickets, diagrams, deps
```

---

## Project Discovery

**Trigger:** `docs/ai-docs/_index.md` has `[TBD]` placeholders.
Ask user before starting, then load `.claude/discovery.md`.

---

## Session Start

**Trigger: every new conversation** (including `/clear`, project switch). Execute automatically.

1. **Verify protected directories exist.** Any missing → recreate per File Safety section below.
2. **Read `docs/ai-docs/_status.md`** only (10–20 lines). Do NOT auto-load `_memory.md`, `_index.md`, or tickets.
3. **Report status** based on `_status.md`:
   - Active wip + test fail → "진행 중인 작업 있음: `<stem>` (테스트 실패). 계속할까요?"
   - Active wip + impl done, no test → "`<stem>` 구현 완료. `/test <stem>` 준비됨."
   - Active wip + no impl → "계획된 작업 있음: `<stem>`. `/implement <stem>` 준비됨."
   - No active wip → CMD별 기본 대기 메시지

---

## Agent Routing

**`@explorer` (Haiku):** read-only investigation, file search, codebase scan. Spawn multiple in parallel.
**`@reviewer` (Sonnet):** code review, test generation, single-module refactoring.
**Main conversation (Opus):** architecture decisions, cross-module changes.

**Subagent output verification** — always verify paths/names against actual files before using. Hallucinated snippets in reports are a hard failure.
**Parallel dispatch:** 3+ independent tasks, no shared files. **Sequential:** task B needs A's output, or shared files.

---

## Task Intake Protocol

When user requests a feature, do not implement immediately:

1. **Assess scope** — complexity, affected modules.
2. **Ask only what's ambiguous** — module, dependencies, priority.
3. **Propose strategy** — parallel vs sequential, which agents.
4. **Wait for confirmation.**

**Skip questions for:** single-file changes, obvious bug fixes.
**"Just do it" mode:** skip questions, choose optimal strategy, report after.

---

## Slash Commands

`/plan`, `/implement`, `/test` form a **document chain** — each reads the previous step's output. Details in each skill file (`skills/`). All other skills also in `skills/`.

---

## Project Knowledge

Architecture lives in `docs/ai-docs/_index.md`. Load only when needed. Update only when architecture changes.
All AI-authored artifacts in **English**. Human-facing UI strings exempt.
Tickets: `docs/ai-docs/tickets/<status>/YYMMDD-<n>.md`. Append `### Result (<hash>)` on phase completion.

---

## _status.md

Single source of truth for "what's in flight." Stay under 20 lines.
Updated by `/plan`, `/implement`, `/test`, commit. Not a history file — current state only. History → `_memory.md`.

---

## Code Standards

1. **Simplicity.** Simplest code that works. Implement fully when spec is clear.
2. **Surgical changes.** Change only what the task requires. Follow existing style.
3. **Module structure.** Split files at ~300 lines. Entry file with public re-exports only.
4. **Build modes.** `/test` always debug. Release only by explicit user request after human testing.

---

## Honesty

If you cannot find a referenced document, function, or fact, **say so explicitly**.
Never fabricate file paths, function names, ticket stems, or file contents.
"I don't know" and "I couldn't find it" are valid answers — guessing is not.
When unsure between two interpretations, ask the user rather than pick one silently.

---

## Workflow

### Approval Protocol

| Category | Action |
|:---|:---|
| **Auto-proceed** | Bug fixes, pattern-following, test code, single-module refactor |
| **Ask first** | New components, architecture changes, cross-module interfaces |
| **Always ask** | Deleting functionality, API semantics, persistence schema |

### File Safety

**Deletion policy:** Never delete files directly. Always trash first:
```bash
mv -n <file> docs/ai-docs/_trash/
```
`_trash/` is emptied by user only — Claude never empties it.

**Destructive commands:** `settings.json` hard-blocks `rm`, `git stash`, `git clean`, `git checkout --`, `git restore`, `rmdir`, `rd /s`.
Additionally: `rm -rf` on any `docs/` path is **absolutely prohibited** — even if user says "clean up" or "reset."
For any other destructive command, show exact command + affected paths, wait for explicit "yes." Never infer consent.

**Protected directories** — never delete, move, or empty. Each must have `.gitkeep`:
```
docs/ai-docs/_trash/          docs/ai-docs/diagrams/
docs/ai-docs/tickets/todo/    docs/ai-docs/mental-model/
docs/ai-docs/tickets/wip/     docs/ai-docs/deps/
docs/ai-docs/tickets/done/    docs/ai-docs/
docs/ai-docs/tickets/dropped/
docs/ai-docs/tickets/idea/
```
If any missing at session start → recreate immediately:
```bash
mkdir -p docs/ai-docs/_trash docs/ai-docs/tickets/{todo,wip,done,dropped,idea} docs/ai-docs/diagrams docs/ai-docs/mental-model docs/ai-docs/deps
touch docs/ai-docs/_trash/.gitkeep docs/ai-docs/tickets/{todo,wip,done,dropped,idea}/.gitkeep
```

### Git Security

- Never commit with company/personal email. Use `@users.noreply.github.com`.
- Before pushing: verify no sensitive data in commit author, file contents, `.git/config`.

### Context Discipline

- **Lazy loading.** Start with `_status.md`, not full docs.
- Source code is ground truth; docs supplement it. If stale, say so.

### Dependency API Notes

`docs/ai-docs/deps/<package>[v<ver>].md` — verified API facts. Read before using; update on wrong signatures.
