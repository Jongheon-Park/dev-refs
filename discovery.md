# Project Discovery — Full Procedure

<!-- Loaded on-demand when discovery is triggered. Not loaded every session. -->

## Step 0: Check for Legacy Rules

| Legacy files | Source | Action |
|:---|:---|:---|
| `0.AI_CORE.md`, `1.AI_ARCHITECTURE.md`, `2.AI_PATH_NAV.md`, `3.AI_DEVLOG.md` | Old Copilot rules | **Migrate** — extract filled data |
| `AI_COPILOT_GUIDE.md` | Copilot-specific | **Skip** |
| `refs/AI_*.md` | Old deep-reference docs | **Skip** |
| `CLAUDE.template.md` | Old Claude template | **Skip** |
| `.github/copilot-instructions.md` | GitHub Copilot | **Read** for context, then ignore |

If legacy files found, inform user and ask to proceed with migration.

**Migration targets:**

| Legacy file | Extract | Migrate to |
|:---|:---|:---|
| `0.AI_CORE.md → # MEMORY` | Build commands, recent work | `CLAUDE.md → # MEMORY` |
| `1.AI_ARCHITECTURE.md` | System overview, modules | `docs/ai-docs/_index.md` + `diagrams/` |
| `2.AI_PATH_NAV.md` | Directory map, key files | `docs/ai-docs/_index.md` |
| `3.AI_DEVLOG.md` | Phase history, current status | `docs/ai-docs/_index.md` |
| `refs/deps/*.md` | Verified API facts | `docs/ai-docs/deps/` |

After extraction, move all legacy files to `docs/_legacy/`.

## Step 1: Detect Tech Stack

| File | Stack |
|:---|:---|
| `.sln` + `.vcxproj` | C++/MFC or C# |
| `CMakeLists.txt` | C/C++ (CMake) |
| `Cargo.toml` | Rust |
| `package.json` | JavaScript/TypeScript |
| `pyproject.toml` / `requirements.txt` | Python |
| `go.mod` | Go |
| `*.csproj` (no .sln) | .NET |

## Step 2–5: Analyze & Document

2. **Map directory structure** — walk top-level dirs, identify each module's role.
3. **Identify key files** — entry points, build configs, core modules.
4. **Check existing docs** — read README.md, CHANGELOG.md, existing arch docs.
5. **Generate diagrams** in `docs/ai-docs/diagrams/`:
   - `dependency-graph.md` — module/package dependency graph (always)
   - `architecture-layers.md` — system layer diagram (always)
   - `data-flow.md` — data flow diagram (if applicable)

## Step 6–9: Finalize

6. **Fill `docs/ai-docs/_index.md`** — replace all placeholders with real data.
7. **Select profiles** — from `docs/profiles/`. Multiple can apply. If none match, create one automatically.
8. **Fill `CLAUDE.md`** — update Project Summary, Tech Stack, Workspace sections.
9. **Present summary to user:**
   - Detected tech stack
   - Selected profiles (and why)
   - Legacy migration results (if applicable)
   - Key findings (entry points, modules, dependencies)
   - Ask: "Project discovery complete. Does this look accurate?"

## Profile Auto-Generation (if no match)

Create `profiles/<language>-<framework>.md` with:
- Language-specific invariants
- Framework patterns and anti-patterns
- Build/test commands
- Threading model if applicable
- Keep under 80 lines

Naming: `<language>-<framework>.md` (lowercase, hyphen-separated)
Examples: `python-fastapi.md`, `typescript-react.md`, `rust-tokio.md`
