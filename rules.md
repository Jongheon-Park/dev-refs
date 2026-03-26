# Rules — Claude Code Universal Rules

<!-- Symlinked into projects as .claude/CLAUDE.md. Edit here → all projects update. -->

## System File Registry

All files that constitute this rule system. When updating rules, **all listed files must be reviewed** — not just the ones mentioned in conversation.

```
0.Rules/
├── rules.md              # Universal rules (this file) — copied as .claude/CLAUDE.md
├── plan.md               # /plan slash command
├── implement.md          # /implement slash command
├── test.md               # /test slash command
├── _status.md            # Session state template
├── discovery.md          # Project discovery procedure
├── agents/               # Subagent definitions
│   ├── explorer.md
│   ├── reviewer.md
│   └── architect.md
├── skills/               # Reusable skill modules
│   └── *.md
└── docs/ai-docs/
    ├── _status.md        # Live session state (per project)
    ├── _index.md         # Architecture index
    ├── _memory.md        # Session history
    ├── _trash/           # Soft-delete staging — emptied manually by user only
    ├── deps/             # Dependency API notes
    ├── diagrams/         # Architecture diagrams
    ├── mental-model/     # Mental model documents
    ├── profiles/         # Stack-specific profiles
    │   └── _legacy/refs/deps/
    └── tickets/
        ├── todo/         # Planned, not started
        ├── wip/          # In progress
        ├── done/         # Completed
        ├── dropped/      # Cancelled
        └── idea/         # Backlog / not yet planned
```

**Rule:** Any update to the workflow (rules.md, slash commands, agents) must be checked against ALL files in this registry for consistency. Partial updates that leave sibling files on an older version are a defect.

---

## Project Discovery

**Trigger:** `docs/ai-docs/_index.md` has `[TBD]` placeholders.

Ask user before starting:
> "This project hasn't been analyzed yet. Shall I run project discovery?"

**Only proceed after user confirms.** Then load `.claude/discovery.md` for full procedure.

---

## Session Start

**Trigger: every time a conversation begins — including after `/clear`, project switch, or any new chat session.**
Claude must execute this automatically without waiting for user instruction.

0. **Verify required directories exist.** Before anything else, check:
   ```bash
   ls docs/ai-docs/tickets/todo docs/ai-docs/tickets/wip docs/ai-docs/tickets/done docs/ai-docs/tickets/dropped docs/ai-docs/tickets/idea
   ```
   Any missing → recreate immediately:
   ```bash
   mkdir -p docs/ai-docs/tickets/todo docs/ai-docs/tickets/wip docs/ai-docs/tickets/done docs/ai-docs/tickets/dropped docs/ai-docs/tickets/idea
   touch docs/ai-docs/tickets/todo/.gitkeep docs/ai-docs/tickets/wip/.gitkeep docs/ai-docs/tickets/done/.gitkeep docs/ai-docs/tickets/dropped/.gitkeep docs/ai-docs/tickets/idea/.gitkeep
   ```
   Report to user if any were missing: "⚠️ Missing directories restored: [list]"

1. **Read `docs/ai-docs/_status.md`** — lightweight state file (10–20 lines). This is the only file read automatically.
2. **Report current status to user** based on its contents:

   | _status.md state | What to say |
   |:---|:---|
   | Active wip, impl done, test FAIL | "진행 중인 작업 있음: `<stem>` (테스트 실패, 재구현 필요). 계속할까요?" |
   | Active wip, impl done, no test yet | "구현 완료된 작업 있음: `<stem>` (테스트 미실행). `/test <stem>` 준비됨." |
   | Active wip, no impl yet | "계획된 작업 있음: `<stem>`. `/implement <stem>` 준비됨." |
   | No active wip | CMD별 기본 대기 상태 (아래 참고) |

3. **CMD-specific default when no active wip:**
   - **CMD 1 (Planner):** "새 작업을 계획할 준비가 됐어요. `/plan <feature>`를 실행하세요."
   - **CMD 2 (Coder):** "진행할 티켓이 없습니다. CMD 1에서 `/plan`을 먼저 실행하세요."
   - **CMD 3 (Tester):** "테스트할 구현 결과물이 없습니다. CMD 2에서 `/implement`을 먼저 실행하세요."

4. **Do NOT auto-load** `_memory.md`, `_index.md`, or any ticket files at session start.
   Load them only when the task explicitly requires them.

---

## Agent Routing

**Use `@explorer` (Haiku):** file search, codebase scan, dependency lookup,
any read-only investigation. Spawn multiple in parallel for independent modules.

**Use `@reviewer` (Sonnet):** code review, test generation, single-module refactoring.

**Use main conversation (Opus):** architecture decisions, cross-module changes,
anything requiring full context.

**Subagent output verification** — ALWAYS required before acting on subagent results:
- Never copy subagent output (file paths, function names, code snippets) directly into reports or code without independently verifying against actual files.
- Verify: `ls` the paths, `grep` the names. If unverifiable → discard and note "unverified" in report.
- Hallucinated code snippets in reports are a hard failure — do not let them propagate to the next CMD.

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

## Slash Command Workflow

The slash commands form a **document chain**. Each step produces output that the next step reads.

### Flow

```
/plan ──────────→ /implement ──────────→ /test
                       ↑                     │
                       │   FAIL_CODE         │
                       └─── failure report ──┘
                                             │
                                   FAIL_DESIGN
                                             │
                       /plan ←───────────────┘  (re-plan)
```

### Document Chain

| Step | Reads | Produces | Saved to |
|:---|:---|:---|:---|
| `/plan` | task description, codebase | plan document | `tickets/todo/YYMMDD-<n>.md` |
| `/implement` | plan + failure report (if any) | code + **implementation report** | `tickets/wip/YYMMDD-impl-report-<n>.md` |
| `/test` | plan + **implementation report** | verification plan + test report | `tickets/wip/YYMMDD-test-report-<n>.md` |

**Rules:**
- `/implement` requires a ticket. Will not proceed without it.
- `/test` requires a ticket AND an implementation report. Will not proceed without both.
- Never start a step without reading the previous step's output.

### Implementation Report

`/implement` must write this before stopping — it is the handoff to `/test`:
- What was done (file by file)
- Deviations from plan (and why)
- Edge cases intentionally excluded
- Known risks to probe during testing

### Loop Structure

On test failure, `/test` classifies the failure type:

**FAIL_CODE** (fixable bugs) → return to `/implement`:
- `/test` saves failure report with exact file:line and suggested fix
- `/implement` reads the failure report before touching any code
- Each loop increments the `attempt:` counter in the report header

**FAIL_DESIGN** (plan/architecture is wrong) → escalate to `/plan`:
- `/test` flags this explicitly and stops the loop
- Do NOT continue with `/implement` until plan is revised

### 3-Strike Rule on the Loop

If `/implement` → `/test` → `/implement` completes 3 times without passing:
- `/test` stops the loop and reports to the user
- Do not suggest a 4th attempt
- User decides: manual review, re-plan, or abandon

---

## Project Knowledge

State and architecture live in `docs/ai-docs/_index.md` (AI-maintained).

**When to read:** Load `_index.md` only when architecture context is needed for the current task.
**When to update:** ONLY when architecture actually changes. NOT after every task.

**Language:** All AI-authored artifacts must be in **English** regardless of conversation language.
Human-facing UI strings are exempt.

**Tickets** (`docs/ai-docs/tickets/<status>/YYMMDD-<n>.md`) track substantial features.
Append `### Result (<short-hash>)` only when completing a ticket phase.

---

## _status.md — Lightweight State File

`docs/ai-docs/_status.md` is the **only file read at every session start**.
It must stay under 20 lines. It is the single source of truth for "what's in flight."

**Updated by:** `/plan`, `/implement`, `/test`, and commit phase (Phase 4 of implement).
**NOT a history file** — only current and last-session state. History lives in `_memory.md`.

---

## Code Standards

1. **Simplicity.** Simplest code that works. Implement fully when spec is clear.
2. **Surgical changes.** Change only what the task requires. Follow existing style.
3. **Module structure.** Split files at ~300 lines. Entry file (`mod.rs`, `index.ts`) with public re-exports only.
4. **Hot-path performance.** Minimal allocation and data locality where benefit outweighs complexity.
5. **Build modes.**
   - All builds during `/test` must use **debug mode**. Never use release flags automatically.
   - Release build is triggered **only by explicit user request** after human testing confirms no issues.
   - If unsure which command is debug vs release, ask the user before building.

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

### File Deletion Policy

**Never delete files directly.** Always move to trash first.

```bash
# 삭제 대신 trash로 이동
mv -n <file> docs/ai-docs/_trash/
```

Rules:
- `mv -n` 필수 — 덮어쓰기 방지 (no-overwrite)
- trash 경로: `docs/ai-docs/_trash/` (없으면 먼저 생성)
- `_trash/`는 사용자가 직접 비움 — Claude가 비우지 않음
- `git stash`, `git clean`, `rm`, `rmdir` 은 settings.json deny로 하드 차단됨

### Destructive Command Gate

**ABSOLUTE PROHIBITION — Claude must NEVER run these commands on `docs/` paths, under any circumstances, even if user says "clean up" or "reset":**

```
rm -rf docs/
rd /s docs/
git clean -fd
git clean -fx
git clean -f docs/
rmdir /s docs/
```

These commands destroy untracked files permanently. Tickets that are not yet committed will be lost forever.

**For ALL other destructive commands** (outside `docs/`), Claude MUST show the exact command and wait for explicit confirmation:
> "⚠️ This command will permanently delete/modify files:
> `<exact command>`
> Affected paths: `<list>`
> Proceed? (yes/no)"

**Never infer consent.** "Clean up", "reorganize", "reset" from the user does NOT authorize destructive commands. Ask explicitly.

### Protected Directories

The following directories must NEVER be deleted, moved, or emptied — even if they appear empty:

```
docs/ai-docs/_trash/
docs/ai-docs/tickets/todo/
docs/ai-docs/tickets/wip/
docs/ai-docs/tickets/done/
docs/ai-docs/tickets/dropped/
docs/ai-docs/tickets/idea/
docs/ai-docs/diagrams/
docs/ai-docs/mental-model/
docs/ai-docs/deps/
docs/ai-docs/
```

- Each must contain a `.gitkeep` file so git tracks the empty directory.
- If any of these are missing at session start → recreate immediately before any other work:
  ```bash
  mkdir -p docs/ai-docs/_trash docs/ai-docs/tickets/todo docs/ai-docs/tickets/wip docs/ai-docs/tickets/done docs/ai-docs/tickets/dropped docs/ai-docs/tickets/idea docs/ai-docs/diagrams docs/ai-docs/mental-model docs/ai-docs/deps
  touch docs/ai-docs/_trash/.gitkeep docs/ai-docs/tickets/todo/.gitkeep docs/ai-docs/tickets/wip/.gitkeep docs/ai-docs/tickets/done/.gitkeep docs/ai-docs/tickets/dropped/.gitkeep docs/ai-docs/tickets/idea/.gitkeep
  ```
- **NEVER run `rm -rf` on any path under `docs/ai-docs/`.** If cleanup is needed, move files — do not delete directories.

### Git Security

- Never commit with company/personal email. Use `@users.noreply.github.com`.
- Before pushing public: verify no sensitive data in commit author, file contents, `.git/config`.

### Context Discipline

- **Lazy loading.** Never preload all docs. Start with `_status.md`, not full docs.
- Source code is ground truth; docs supplement it.
- If docs are stale, say so rather than speculating.

### Dependency API Notes

`docs/ai-docs/deps/<package>[v<ver>].md` — verified API facts for packages with API drift.
Read before using a listed package. Update after discovering wrong signatures or renamed types.
