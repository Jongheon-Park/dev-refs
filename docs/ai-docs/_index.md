# [PROJECT_NAME] — Project Index

<!-- AI-maintained. Source of truth for project state and architecture.
     Load ONLY when task requires architecture context.
     Update ONLY when architecture actually changes (new module, deps, build config). -->

## Operational State

- **Status**: [development / staging / production]
- **Build**: [passing / failing / unknown]
- **Last verified**: [YYYY-MM-DD]

## Architecture Overview

<!-- High-level system design. Keep concise — link to module docs for details. -->

### System Layers

```
┌─────────────────────────────────────┐
│     [LAYER 1 — e.g. UI / API]      │
├─────────────────────────────────────┤
│     [LAYER 2 — e.g. Business]      │
├─────────────────────────────────────┤
│     [LAYER 3 — e.g. Data/Infra]    │
└─────────────────────────────────────┘
```

### Core Modules

| Module | Location | Responsibility | Dependencies |
|:---|:---|:---|:---|
| [Module1] | `src/[path]` | [description] | [deps] |
| [Module2] | `src/[path]` | [description] | [deps] |

### External Dependencies

| Dependency | Version | Purpose |
|:---|:---|:---|
| [lib1] | [ver] | [purpose] |
| [lib2] | [ver] | [purpose] |

## Directory Map

```
[project-root]/
├── src/            — Source code
│   ├── [module1]/  — [purpose]
│   └── [module2]/  — [purpose]
├── tests/          — Test files
├── docs/           — Documentation
├── config/         — Configuration files
└── scripts/        — Build/deploy scripts
```

## Key Files

| File | Role |
|:---|:---|
| `[entry-point]` | Application entry point |
| `[config-file]` | Main configuration |
| `[build-file]` | Build configuration (e.g. CMakeLists.txt, package.json) |

## Threading / Concurrency Model

<!-- Remove this section if not applicable. -->

- **Main thread**: [role]
- **Worker threads**: [role, communication method]
- **Synchronization**: [primitives used]

## Build Configuration

| Config | Platform | Output | Notes |
|:---|:---|:---|:---|
| Debug | [arch] | `[path]` | [flags] |
| Release | [arch] | `[path]` | [flags] |

## Diagrams

<!-- AI-generated mermaid diagrams. See ai-docs/diagrams/ for source. -->

- [Dependency Graph](diagrams/dependency-graph.md) — module/package relationships
- [Architecture Layers](diagrams/architecture-layers.md) — system layer overview
- [Data Flow](diagrams/data-flow.md) — processing pipeline (if applicable)

## Module Documentation

<!-- Add links as module docs are created. -->

- [Module1]: `ai-docs/modules/[module1].md`

## Tech Profile

<!-- Set during discovery. Multiple profiles can be active. -->

- **Detected stack**: [language + framework + key libs]
- **Active profiles**:
  - `profiles/[stack].md` — [reason: e.g. "MFC UI detected"]
  - `profiles/[lib].md` — [reason: e.g. "OpenCV dependency found"]

---

**Last Updated:** [YYYY-MM-DD]
