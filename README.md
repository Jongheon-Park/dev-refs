# dev-refs

Personal archive for development guidelines and CLI workspace contexts.

---

## AI Rules — Drop-in Project Kit

A universal project rules kit for Claude Code.
Rules and project data are **separated** — update rules once, all linked projects get the change.

---

## Structure

```
dev-refs/                          (this repo)
├── CLAUDE.md                      ← Project data template
├── rules.md                       ← Universal rules (symlinked into projects)
├── setup.sh                       ← One-command deploy + update script
├── VERSION                        ← Current kit version
├── CHANGELOG.md                   ← Release notes
├── agents/                        ← Subagent definitions (symlinked into projects)
│   ├── architect.md               (Opus, deep design)
│   ├── reviewer.md                (Sonnet, code review)
│   └── explorer.md                (Haiku, read-only)
├── skills/                        ← Slash command skills (copied into projects)
│   ├── plan.md                    Phase 1 — Plan
│   ├── discuss.md                 Phase 1 — Plan
│   ├── research.md                Phase 1 — Plan
│   ├── write-ticket.md            Phase 1 — Plan
│   ├── implement.md               Phase 2 — Code
│   ├── review.md                  Phase 2 — Code
│   ├── document-dependency.md     Phase 2 — Code
│   ├── test.md                    Phase 3 — Test
│   ├── rebuild-docs.md            Phase 3 — Test
│   └── chat-over-session.md       (cross-session utility)
└── docs/
    ├── ai-docs/                   ← Project state/diagrams/tickets store
    │   ├── _index.md
    │   ├── diagrams/
    │   ├── deps/
    │   └── tickets/{idea,todo,wip,done,dropped}/
    ├── examples/                  ← Path B subagent examples (opt-in)
    │   └── subagents/
    └── profiles/                  ← Stack-specific rules (auto-generated during Discovery)
```

## Setup

### 0. Prerequisites (per public project)

Set a safe git email to prevent company/personal email exposure in public repos.
Do NOT use `--global` if you also use a company GitLab — set per project instead:

```bash
cd <project-root>
git config user.email "<your-github-username>@users.noreply.github.com"
```

Also add these to your project's `.gitignore`:

```
.env
.env.*
*.key
*.pem
credentials.json
secrets.json
```

### 1. Deploy to a project

```bash
bash /path/to/dev-refs/setup.sh <project-root>
```

This will:
- Copy `CLAUDE.md` (skips if already exists)
- Copy `docs/ai-docs/` and `docs/profiles/`
- Create ticket directories (`idea/`, `todo/`, `wip/`, `done/`, `dropped/`)
- Copy `skills/` → `.claude/commands/` (each file skipped if already exists)
- Symlink `rules.md` → `<project>/.claude/CLAUDE.md`

Result in project:
```
project-root/
├── CLAUDE.md              ← Project data (Summary, Tech Stack, MEMORY)
├── .claude/
│   ├── CLAUDE.md          → symlink to dev-refs/rules.md
│   └── commands/          ← Skills (/plan, /implement, ...)
└── docs/
    ├── ai-docs/
    │   ├── _index.md
    │   ├── diagrams/
    │   ├── deps/
    │   └── tickets/
    └── profiles/
```

Claude Code auto-loads both `CLAUDE.md` and `.claude/CLAUDE.md`, so rules
and project data are both available every session.

### 2. Update dev-refs

**Step A** — Pull the latest kit:
```bash
cd /path/to/dev-refs && git pull
```

**Step B** — Refresh kit-owned files in each project:
```bash
bash /path/to/dev-refs/setup.sh <project-root> --update
```

The `--update` mode refreshes:
- `.claude/CLAUDE.md`, `.claude/discovery.md` (rules)
- `.claude/agents/` (subagent definitions)
- `.claude/commands/` (slash command skills)
- `.claude/settings.json` (SessionStart hook — installed if missing)

User-owned files are **never touched**:
- `CLAUDE.md` (project data)
- `docs/profiles/` (your stack rules)
- `docs/ai-docs/` (project state, tickets, deps, mental-model)

**Note**: On systems where symlinks work (Linux/macOS, Windows with developer mode),
`rules.md` and `agents/` auto-update on `git pull` alone — Step B is only needed
to refresh `skills/` (which is always copied) and to install missing
`settings.json`. On Windows without developer mode, all kit files are copies
and Step B is required for any update to take effect.

> **Note:** If `git pull` fails with `fatal: refusing to merge unrelated histories`,
> delete and re-clone dev-refs (your project files are unaffected):
> ```bash
> rm -rf /path/to/dev-refs
> git clone https://github.com/Jongheon-Park/dev-refs.git /path/to/dev-refs
> ```

### 3. Scenarios

#### A) New project

1. Run `setup.sh`
2. On the first session, the AI asks "Shall I run project discovery?"
3. On confirmation, Discovery runs automatically

#### B) Existing project (no AI rules)

Same as A. Analyzes and documents existing source code.

#### C) Existing project (with Copilot rules)

1. Run `setup.sh` (alongside existing `0.AI_CORE.md`, etc.)
2. AI auto-detects existing files and asks to migrate
3. On confirmation: extracts data → new structure → old files → `docs/_legacy/`

#### D) Existing project (with Copilot + Claude rules)

1. Run `setup.sh` (CLAUDE.md is skipped since it already exists)
2. Manually remove the rules section from existing `CLAUDE.md` — keep project data + MEMORY only
3. Rules are now served by the symlinked `.claude/CLAUDE.md`

---

## Skills

Markdown files in `skills/` are copied to `.claude/commands/` on deployment.
Run with `/command-name` in Claude Code.

### Phase 1 — Plan

Documents only. No source code changes.

| Command | Description |
|:---|:---|
| `/plan <feature>` | Research → design → save ticket. Verified by subagent. |
| `/discuss <topic>` | Open brainstorming. No file changes. Challenge assumptions. |
| `/research <question>` | Anti-hallucination analysis. Cite or "I don't know." |
| `/write-ticket <topic>` | Create/edit tickets. `idea/`→`todo/`→`wip/`→`done/` |

### Phase 2 — Code

Read documents, write code. Requires a ticket.

| Command | Description |
|:---|:---|
| `/implement <stem>` | Verify plan → code → security check → commit + report. |
| `/review <target>` | Code review. Critical/Important/Minor classification. |
| `/document-dependency <pkg>` | Document external library API against actual source. |

### Phase 3 — Test

Build + verify. No code changes. Hand failures back to Phase 2.

| Command | Description |
|:---|:---|
| `/test <stem>` | Build + test → write test report. No source edits. |
| `/rebuild-docs` | Regenerate `_index.md` and `mental-model/` from current source. |

### Utility

| Command | Description |
|:---|:---|
| `/chat-over-session <name>` | File-based messaging between two Claude Code sessions. |

### Single-Conversation Workflow

Run all phases in **one conversation** with `/clear` between phases. State
persists in `docs/ai-docs/tickets/` (the document chain) and `_status.md`
auto-loads via SessionStart hook after each `/clear`, so the next phase knows
where to pick up.

```
/plan <feature>
       │
       └──→ ticket saved in docs/ai-docs/tickets/todo/
       │
   /clear                   ← context reset; _status.md auto-loads
       │
/implement <stem>
       │
       ├──→ reads ticket from disk
       └──→ impl-report saved in docs/ai-docs/tickets/wip/
       │
   /clear                   ← context reset; _status.md auto-loads
       │
/test <stem>
       │
       ├──→ reads ticket + impl-report from disk
       └──→ test-report saved in docs/ai-docs/tickets/wip/
       │
       │   verdict: PASS / FAIL_CODE / FAIL_DESIGN
       │
       (PASS only)
       │
   commit                   ← ticket → tickets/done/
```

**Why single-conversation?**
- No 3-terminal setup. One conversation, three phases via slash commands.
- `/clear` between phases keeps each phase's context lean (no token bloat).
- Document chain (ticket → impl-report → test-report) carries state across clears.
- Role boundaries are enforced by each skill's PROHIBITED section, not by
  separate terminals.

**Cost optimization (optional)**: Switch model per phase before each command:
```
/model opus    /plan <feature>
/clear
/model sonnet  /implement <stem>
/clear
/model sonnet  /test <stem>
```
Skills don't enforce model — your call. For automated model dispatch, see
**Advanced — Path B (Subagent Dispatch)** below.

---

## Diagrams

### File Relationship

How Claude Code loads files at runtime:

```mermaid
flowchart TD
    subgraph dev-refs["dev-refs (this repo)"]
        R[rules.md]
    end

    subgraph project["project-root"]
        CM[CLAUDE.md<br/><i>project data</i>]
        SL[.claude/CLAUDE.md<br/><i>symlink</i>]
        IDX[docs/ai-docs/_index.md]
        DIAG[docs/ai-docs/diagrams/]
        DEPS[docs/ai-docs/deps/]
        TIX[docs/ai-docs/tickets/]
        PROF[docs/profiles/*.md]
    end

    R -. symlink .-> SL
    CC[Claude Code] == auto-load ==> CM
    CC == auto-load ==> SL
    CC -. on-demand .-> IDX
    CC -. on-demand .-> DIAG
    CC -. on-demand .-> DEPS
    CC -. on-demand .-> TIX
    CC -. on-demand .-> PROF
```

### File Contents

What each file is responsible for:

```mermaid
block-beta
    columns 3

    block:claude["CLAUDE.md (per-project)"]:1
        columns 1
        A["Project Summary"]
        B["Tech Stack"]
        C["Workspace"]
        D["Architecture Rules"]
        E["MEMORY"]
    end

    block:rules["rules.md (shared)"]:1
        columns 1
        F["Project Discovery"]
        G["Session Start"]
        H["Code Standards"]
        I["Workflow & Process"]
        J["Context Discipline"]
    end

    block:skills["skills/ → .claude/commands/"]:1
        columns 1
        K["Phase 1 (Plan): plan, discuss, research, write-ticket"]
        L["Phase 2 (Code): implement, review, document-dependency"]
        M["Phase 3 (Test): test, rebuild-docs"]
        N["Utility: chat-over-session"]
    end
```

### Deploy Flow

What `setup.sh` does:

```mermaid
flowchart TD
    A["bash setup.sh project-root"] --> B{CLAUDE.md exists?}
    B -->|No| C[Copy CLAUDE.md]
    B -->|Yes| D[Skip]

    A --> E{docs/ai-docs/ exists?}
    E -->|No| F[Copy docs/ai-docs/]
    E -->|Yes| G[Skip]

    A --> H{docs/profiles/ exists?}
    H -->|No| I[Copy docs/profiles/]
    H -->|Yes| J[Skip]

    A --> S["Copy skills/ → .claude/commands/<br/>(each file: skip if exists)"]

    A --> K{.claude/CLAUDE.md exists?}
    K -->|No| L["Create symlink<br/>→ rules.md"]
    K -->|Symlink| M[Skip]
    K -->|Regular file| N["Warn: remove first"]

    C --> O[Ready]
    D --> O
    F --> O
    G --> O
    I --> O
    J --> O
    S --> O
    L --> O
    M --> O
```

---

## Recording System — 3 Layers

Project knowledge is managed in 3 layers.

```
docs/ai-docs/
├── _index.md          ← Layer 1: Architecture (rarely changes)
├── _memory.md         ← Layer 2: Session memory (updated each session)
├── mental-model/      ← Layer 3: Operational knowledge (updated after code changes)
├── deps/              ← External API facts
├── tickets/           ← Work records and reports
└── diagrams/          ← Architecture diagrams
```

| Layer | File | When updated | Content |
|:---|:---|:---|:---|
| 1 | `_index.md` | Architecture changes | Module map, build config, tech stack |
| 2 | `_memory.md` | Every session start/end | Recent work, pending items, ephemeral notes |
| 3 | `mental-model/*.md` | After code changes | Contracts, coupling, extension points, gotchas |

### Document Production Map

| Document Type | Filename Pattern | Location | Producer | Consumer |
|:---|:---|:---|:---|:---|
| Ticket (plan) | `YYMMDD-<cat>-<name>.md` | `tickets/<status>/` | Phase 1 | Phase 2 |
| Test Report | `YYMMDD-test-report-<stem>.md` | `tickets/wip/` | Phase 3 | Phase 2 |
| Review Report | `YYMMDD-review-report-<stem>.md` | `tickets/wip/` | Phase 2 | Phase 2 |
| Research Report | `YYMMDD-research-<topic>.md` | `tickets/wip/` | Phase 1 | Phase 1, 2 |
| Completion Report | `### Result` in ticket | Existing ticket | Phase 2 | All |
| Dependency Doc | `<pkg>[v<ver>].md` | `deps/` | Phase 2 | Phase 2 |
| Project Doc | `_index.md` + `diagrams/` | `ai-docs/` | Phase 3 | All |
| Session Memory | `_memory.md` | `ai-docs/` | Phase 2 | All |
| Operational Knowledge | `<domain>.md` | `mental-model/` | Phase 3 | All |

## File Roles

| File | Loaded when | Role |
|:---|:---|:---|
| `CLAUDE.md` | **Auto** (every session) | Project data, Architecture Rules, MEMORY |
| `.claude/CLAUDE.md` | **Auto** (every session) | Universal rules (symlink → `rules.md`) |
| `.claude/commands/*.md` | On `/command` execution | Slash command skills |
| `docs/ai-docs/_index.md` | Architecture context needed | Project state, architecture, directory map |
| `docs/ai-docs/_memory.md` | **Session start** | Recent work, pending items, ephemeral notes |
| `docs/ai-docs/mental-model/*.md` | Modifying that domain | Contracts, coupling, gotchas |
| `docs/ai-docs/diagrams/*.md` | Architecture analysis | Mermaid diagrams |
| `docs/ai-docs/deps/*.md` | Using that package | Verified API facts |
| `docs/ai-docs/tickets/*.md` | Working on that task | Tickets, test/review/research reports |
| `docs/profiles/*.md` | Discovery + stack-specific tasks | Stack-specific rules (auto-generated if missing) |

## Token Efficiency

- `CLAUDE.md` + `.claude/CLAUDE.md` stay in context — everything else loads on demand
- **Session start**: `git log --oneline -10` + `_memory.md` to catch up.
  `_index.md` loaded only when architecture context is needed
- **After each task**: No doc updates. Commit messages serve as the devlog
- **MEMORY**: Updated only at session end or on user request
- **Rules separated**: `rules.md` changes propagate via symlink, no per-project edits

## Advanced — Path B (Subagent Dispatch)

The default workflow (Path A) uses slash commands in the main conversation.
If you prefer model-isolated dispatch per phase, see `docs/examples/subagents/`.
Copy the example subagent files to your project's `.claude/agents/` to enable
`@planner`, `@coder`, `@tester` workflow.

Recommended for **Max or higher billing tiers** where token overhead from
subagent context loading is acceptable.

---

**Last Updated:** 2026-04-08
