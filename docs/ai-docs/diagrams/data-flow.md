# Data Flow

<!-- AI-generated during Project Discovery. Only create if the project has
     a clear data processing pipeline. Delete this file if not applicable. -->

```mermaid
flowchart LR
    subgraph Input
        A[Source 1]
        B[Source 2]
    end

    subgraph Processing
        C[Step 1: Preprocessing]
        D[Step 2: Core Processing]
        E[Step 3: Post-processing]
    end

    subgraph Output
        F[Result 1]
        G[Result 2]
    end

    A --> C
    B --> C
    C --> D
    D --> E
    E --> F
    E --> G
```

## Pipeline Stages

| Stage | Input | Output | Notes |
|:---|:---|:---|:---|
| Preprocessing | [raw data] | [cleaned data] | [description] |
| Core Processing | [cleaned data] | [results] | [description] |
| Post-processing | [results] | [final output] | [description] |

---

**Generated:** [YYYY-MM-DD]
**Last Updated:** [YYYY-MM-DD]
