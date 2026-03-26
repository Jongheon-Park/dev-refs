# Rules — Claude Code Universal Rules

<!-- Symlinked into projects as .claude/CLAUDE.md. Edit here → all projects update. -->

## Project Discovery

**Trigger:** `docs/ai-docs/_index.md` has `[TBD]` placeholders.

Ask user before starting:
> "This project hasn't been analyzed yet. Shall I run project discovery?"

**Only proceed after user confirms.** Then load `.claude/discovery.md` for full procedure.

---

## Session Start

1. Run `git log --oneline -10` to catch up on recent work.
2. Read `docs/ai-docs/_index.md` ONLY if the task requires architecture context.
3. Read relevant `docs/profiles/*.md` ONLY if the task involves stack-specific patterns.

---

## Agent Routing

**Use `@explorer` (Haiku):** file search, codebase scan, dependency lookup,
any read-only investigation. Spawn multiple in parallel for independent modules.

**Use `@reviewer` (Sonnet):** code review, test generation, single-module refactoring.

**Use main conversation (Opus):** architecture decisions, cross-module changes,
anything requiring full context.

**Parallel dispatch** — ALL must be true:
- 3+ independent tasks with no shared files
- Results aren't blocking each other
- Example: "analyze auth, database, and API modules" → 3 `@explorer` agents simultaneously

**Sequential dispatch** — ANY triggers it:
- Task B needs output from task A
- Shared files (merge conflict risk)

---

## Task Intake Protocol

When a user makes a feature or task request, **do not implement immediately**. Instead:

1. **Assess scope** — judge complexity and which modules/files are affected.

2. **Ask only what's ambiguous** (skip if obvious):
   - Which module or file should this live in?
   - Are there dependencies between subtasks?
   - Any priority order?

3. **Propose a strategy** — if parallel execution is possible, say so explicitly:
   > "I can split this into 3 independent parts and run them simultaneously:
   > - @explorer: analyze existing auth code
   > - @explorer: research JWT library API
   > - @architect: draft the interface design
   > Proceed in parallel, or would you like to review the design first?"

4. **Wait for confirmation**, then execute.

**When to skip the question and just do it:**
- Clearly scoped single-file changes
- Bug fixes with obvious location

**When user says "just do it" or delegates judgment:**
- Skip questions, but still choose the optimal strategy
- Run parallel if possible, sequential if not — no need to ask
- After completion, briefly report what strategy was used and why

---

## Project Knowledge

State and architecture live in `docs/ai-docs/_index.md` (AI-maintained).

**When to read:** `git log` first. Load `_index.md` only when architecture context needed.
**When to update:** ONLY when architecture actually changes. NOT after every task.

**Language:** All AI-authored artifacts must be in **English** regardless of conversation language.
Human-facing UI strings are exempt.

**Tickets** (`docs/ai-docs/tickets/<status>/YYMMDD-<name>.md`) track substantial features.
Append `### Result (<short-hash>)` only when completing a ticket phase.

---

## Code Standards

1. **Simplicity.** Simplest code that works. Implement fully when spec is clear.
2. **Surgical changes.** Change only what the task requires. Follow existing style.
3. **Module structure.** Split files at ~300 lines. Entry file (`mod.rs`, `index.ts`) with public re-exports only.
4. **Hot-path performance.** Minimal allocation and data locality where benefit outweighs complexity.

---

## Workflow

### Approval Protocol

| Category | Action |
|:---|:---|
| **Auto-proceed** | Bug fixes, pattern-following additions, test code, single-module refactoring |
| **Ask first** | New components, architectural changes, cross-module interface changes |
| **Always ask** | Deleting functionality, changing API semantics, modifying persistence schema |

### Implementation Process

1. **Clarify & plan.** State assumptions and success criteria for non-trivial changes.
2. **Implement & test.** Write unit tests for non-trivial pure logic. **3-strike rule:** same issue after 3 attempts → stop and ask.
3. **Verify.** Run full test suite. Run build step after editing relevant files.
4. **Update docs.** MEMORY at session end only. `_index.md` only when architecture changes.
5. **Commit.**

```
<type>(<scope>): <summary>

<what changed — brief>

## AI Context
- <decision rationale, rejected alternatives, trade-offs>

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Git Security

- Never commit with company/personal email. Use `@users.noreply.github.com`.
- Before pushing public: verify no sensitive data in commit author, file contents, `.git/config`.

### Context Discipline

- **Lazy loading.** Never preload all docs. Start with `git log`, not docs.
- Source code is ground truth; docs supplement it.
- If docs are stale, say so rather than speculating.

### Dependency API Notes

`docs/ai-docs/deps/<package>[v<ver>].md` — verified API facts for packages with API drift.
Read before using a listed package. Update after discovering wrong signatures or renamed types.
