# Architecture Layers

<!-- AI-generated during Project Discovery. Update when layer structure changes. -->

```mermaid
graph TB
    subgraph Presentation ["Presentation Layer"]
        UI[UI / API Endpoints]
    end

    subgraph Business ["Business Logic Layer"]
        Core[Core Logic]
        Services[Services]
    end

    subgraph Data ["Data / Infrastructure Layer"]
        DB[Data Access]
        External[External APIs]
    end

    UI --> Core
    UI --> Services
    Core --> DB
    Services --> External
```

## Layer Responsibilities

| Layer | Components | Responsibility |
|:---|:---|:---|
| **Presentation** | [list] | User interaction, input handling, display |
| **Business Logic** | [list] | Core algorithms, business rules, processing |
| **Data/Infra** | [list] | Persistence, external communication, shared utilities |

## Rules

- Upper layers may depend on lower layers, **not the reverse**.
- Cross-layer communication through defined interfaces only.

---

**Generated:** [YYYY-MM-DD]
**Last Updated:** [YYYY-MM-DD]
