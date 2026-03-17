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
├── setup.sh                       ← One-command deploy script
└── docs/
    ├── ai-docs/                   ← Project state/diagrams/tickets store
    │   ├── _index.md
    │   ├── diagrams/
    │   ├── deps/
    │   └── tickets/
    └── profiles/                  ← Stack-specific rules
        ├── cpp-mfc.md
        ├── cpp-imgui.md
        └── cpp-opencv.md
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
- Symlink `rules.md` → `<project>/.claude/CLAUDE.md`

Result in project:
```
project-root/
├── CLAUDE.md              ← Project data (Summary, Tech Stack, MEMORY)
├── .claude/
│   └── CLAUDE.md          → symlink to dev-refs/rules.md
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

```bash
cd /path/to/dev-refs && git pull
```

Symlinked `rules.md` updates automatically in all linked projects.

> **Note:** If `git pull` fails with `fatal: refusing to merge unrelated histories`,
> delete and re-clone:
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
    columns 2

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
    L --> O
    M --> O
```

---

## File Roles

| File | Loaded when | Role |
|:---|:---|:---|
| `CLAUDE.md` | **Auto** (every session) | Project data, Architecture Rules, MEMORY |
| `.claude/CLAUDE.md` | **Auto** (every session) | Universal rules (symlink → `rules.md`) |
| `docs/ai-docs/_index.md` | Architecture context needed | Project state, architecture, directory map |
| `docs/ai-docs/diagrams/*.md` | Architecture analysis | Mermaid diagrams |
| `docs/ai-docs/deps/*.md` | Using that package | Verified API facts |
| `docs/ai-docs/tickets/*.md` | Working on that task | Feature tickets, phased progress |
| `docs/profiles/*.md` | Discovery + stack-specific tasks | Stack-specific rules (auto-generated if missing) |

## Token Efficiency

- `CLAUDE.md` + `.claude/CLAUDE.md` stay in context — everything else loads on demand
- **Session start**: `git log --oneline -10` (~10 lines) to catch up.
  `_index.md` loaded only when architecture context is needed
- **After each task**: No doc updates. Commit messages serve as the devlog
- **MEMORY**: Updated only at session end or on user request
- **Rules separated**: `rules.md` changes propagate via symlink, no per-project edits

## docs/_legacy/

Previous versions of rule files (0.AI_CORE.md, refs/, etc.).
Automatically moved after migration. Kept for reference. Do not copy to new projects.

---

**Last Updated:** 2026-03-17
