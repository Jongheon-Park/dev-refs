# Rules — Claude Code Universal Rules

<!-- This file is symlinked into projects as .claude/CLAUDE.md.
     Loaded automatically by Claude Code alongside the project CLAUDE.md.
     Edit here → all linked projects get the update. -->

## Project Discovery

**Trigger:** `docs/ai-docs/_index.md` still contains `[TBD]` or bracket placeholders.

When this is a **first session** on a project (placeholders detected), **ask the
user before starting analysis**:

> "This project hasn't been analyzed yet. Shall I run project discovery?
> This will scan the project structure, detect the tech stack, and generate
> architecture documentation."

**Only proceed after user confirms.** Then execute:

### Step 0: Check for Legacy Rules

Before scanning the project, check for **pre-existing AI rule systems**:

| Legacy files | Source | Action |
|:---|:---|:---|
| `0.AI_CORE.md`, `1.AI_ARCHITECTURE.md`, `2.AI_PATH_NAV.md`, `3.AI_DEVLOG.md` | Old Copilot rules | **Migrate** — extract filled data |
| `AI_COPILOT_GUIDE.md` | Copilot-specific | **Skip** — not compatible |
| `refs/AI_*.md` | Old deep-reference docs | **Skip** — superseded by profiles |
| `CLAUDE.template.md` | Old Claude template | **Skip** — replaced by this file |
| `.github/copilot-instructions.md` | GitHub Copilot | **Read** for project context, then ignore |

**If legacy files found**, inform user:

> "I found existing AI rule files (old Copilot format). I'll extract useful
> information (architecture, devlog, build commands, MEMORY) and migrate it
> to the new structure. The old files will be moved to `docs/_legacy/`.
> Proceed?"

**Migration extraction targets:**

| Legacy file | Extract | Migrate to |
|:---|:---|:---|
| `0.AI_CORE.md` → `# MEMORY` section | Build commands, recent work, workspace ref | `CLAUDE.md → # MEMORY` |
| `1.AI_ARCHITECTURE.md` (filled sections) | System overview, modules, dependencies, threading | `docs/ai-docs/_index.md` + `docs/ai-docs/diagrams/` |
| `2.AI_PATH_NAV.md` (filled sections) | Directory map, key file patterns | `docs/ai-docs/_index.md → Directory Map` |
| `3.AI_DEVLOG.md` (completed phases) | Phase history, current status | `docs/ai-docs/_index.md → Operational State` |
| `refs/deps/*.md` | Verified API facts | `docs/ai-docs/deps/` (copy as-is) |

After extraction, move all legacy files to `docs/_legacy/` folder.

### Step 1: Detect Tech Stack

Scan for project files:

| File | Stack |
|:---|:---|
| `.sln` + `.vcxproj` | C++/MFC or C# |
| `CMakeLists.txt` | C/C++ (CMake) |
| `Cargo.toml` | Rust |
| `package.json` | JavaScript/TypeScript |
| `pyproject.toml` / `requirements.txt` | Python |
| `go.mod` | Go |
| `*.csproj` (no .sln) | .NET |

### Step 2–5: Analyze & Document

2. **Map directory structure** — walk top-level dirs, identify each module's role.
3. **Identify key files** — entry points, build configs, core modules.
4. **Check existing docs** — read README.md, CHANGELOG.md, existing arch docs.
5. **Generate diagrams** — create mermaid diagrams in `docs/ai-docs/diagrams/`:
   - `dependency-graph.md` — module/package dependency graph (always)
   - `architecture-layers.md` — system layer diagram (always)
   - `data-flow.md` — data flow diagram (if applicable)

### Step 6–9: Finalize

6. **Fill `docs/ai-docs/_index.md`** — replace all placeholders with real data.
   If legacy data was migrated, merge it with fresh scan results.
7. **Select profiles** — based on detected stack and dependencies, automatically
   select all applicable profiles from `docs/profiles/`. Multiple profiles can apply
   (e.g. `cpp-imgui.md` + `cpp-opencv.md` for an ImGui app with OpenCV).
   If no profile matches the detected stack, **create a new one** automatically.
   List selected profiles in `docs/ai-docs/_index.md → Tech Profile` section.
8. **Fill `CLAUDE.md`** — update Project Summary, Tech Stack, Workspace sections.
9. **Present summary to user** — include:
   - Detected tech stack
   - Selected profiles (and why)
   - Legacy migration results (if applicable)
   - Key findings (entry points, modules, dependencies)
   - Ask: "Project discovery complete. Does this look accurate?
     Should I adjust the selected profiles?"

---

### Session Start

1. Run `git log --oneline -10` to catch up on recent work.
2. Read `docs/ai-docs/_index.md` ONLY if the task requires architecture context.
3. Read relevant `docs/profiles/*.md` ONLY if the task involves stack-specific patterns.

## Project Knowledge

Project state, architecture, and source layout live in **`docs/ai-docs/_index.md`**.
All files under `docs/ai-docs/` are AI-maintained; this is the primary cross-session
context store.

**When to read:** Use `git log` first. Load `_index.md` only when architecture
context is needed. Load relevant module docs before tasks.
**When to update:** ONLY when architecture actually changes (new module,
dependency change, build config change). NOT after every task.

**Language:** All AI-authored artifacts — documents, plans, commit messages,
`### Result` entries, `MEMORY` sections, and inline code comments — must be
in **English**, regardless of conversation language. Human-facing UI strings
are exempt.

**Tickets** (`docs/ai-docs/tickets/<status>/YYMMDD-<name>.md`) track substantial
features and multi-phase work.

- Phases requiring design before coding are marked **(plan mode)** — use the
  `EnterPlanMode` tool, explore + design, get user approval, then `ExitPlanMode`.
- After completing a ticket phase, append a `### Result (<short-hash>)` recording:
  what was implemented, deviations from plan, key findings for future phases.

## Code Standards

1. **Simplicity.** Write the simplest code that works. Implement fully when spec
   is clear — judge scope by AI effort, not human-hours.
2. **Surgical changes.** Change only what the task requires. Follow existing style.
   Every changed line must trace to the request.
3. **Module structure.** Split files at ~300 lines. Extract an entry file
   (e.g. `mod.rs`, `index.ts`, `__init__.py`) with doc comments and public
   re-exports only — reading it alone conveys the module's interface.
4. **Hot-path performance.** In performance-critical paths, prefer minimal
   allocation and data locality. Apply only when benefit clearly outweighs
   complexity cost.

## Workflow

### Approval Protocol

| Category | Action |
|:---|:---|
| **Auto-proceed** | Bug fixes, pattern-following additions, test code, boilerplate, single-module refactoring |
| **Ask first** | New components, architectural changes, cross-module interface changes, behavior changes |
| **Always ask** | Deleting functionality, changing API semantics, modifying persistence schema |

### Implementation Process

1. **Clarify & plan.** For non-trivial changes, state assumptions and success
   criteria. Break work into steps via `TaskCreate`. Check them off as you go.
2. **Implement & test.** Write unit tests alongside non-trivial pure logic.
   When tests fail, diagnose whether the **test** or the **implementation** is
   wrong — don't blindly fix implementation to match a bad test.
   For UI/visual features, request manual testing instead.
   **3-strike rule:** If the same issue survives 3 fix attempts, stop and
   ask user — likely an architectural problem, not a code bug.
3. **Verify.** Run the full test suite. If the project has a build step, run it
   after editing relevant files to catch errors early. All checks must pass.
4. **Update docs.** Minimize doc updates to save tokens. Rules:
   - **MEMORY section**: Update ONLY at session end or when user requests.
     Keep max 3 recent items. Never update mid-task.
   - **docs/ai-docs/_index.md**: Update ONLY when architecture actually changes
     (new module, dependency change, build config change). NOT for every task.
   - **Tickets**: Append `### Result` only when completing a ticket phase.
   - **History**: Git commit messages serve as the devlog.
     Use `git log --oneline -10` to review recent work instead of reading docs.
   - **Inclusion test:** Record only if (1) not knowing it causes silent failure
     AND (2) not derivable from source in ~30 seconds. Delete everything else.
5. **Commit.** Auto-create git commits by logical unit. Format:

   ```
   <type>(<scope>): <summary>

   <what changed — brief>

   ## AI Context
   - <decision rationale, rejected alternatives, trade-offs>

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```

### Git Security

- **Never commit** with company/personal email. Use `@users.noreply.github.com`.
- **Before pushing to public repo**, verify no sensitive data in:
  - Commit author (`git log --format="%an <%ae>"`)
  - File contents (API keys, internal IPs, server addresses, credentials)
  - `.git/config` (credential settings — not pushed but check anyway)
- **If sensitive data found in history**: re-init git and force push clean history.

### Evidence & Analysis

- Cite `file:line` for factual claims about code.
- Do not speculate. If unknown, state it explicitly.
- When tracing function behavior, follow the call chain (minimum 2 levels)
  before drawing conclusions.

### Context Discipline

- **Lazy loading.** Never preload all docs. Load each doc only when the
  conversation reaches that module. Start with `git log`, not docs.
- Source code is the ground truth; docs supplement it.
- When a doc drifts from source, update the doc (or flag it).
- If docs are stale or insufficient, say so rather than speculating.

### Dependency API Notes

- **`docs/ai-docs/deps/<package>[v<ver>].md`** stores verified API facts for
  libraries whose actual API differs from training knowledge.
- **Read** before writing code that uses a listed package.
- **Write/update** after discovering API drift (wrong signatures, renamed types,
  removed methods).
