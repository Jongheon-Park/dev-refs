# Mental Model

Operational knowledge for modifying the codebase.
NOT API references. NOT source code descriptions.

## Inclusion Test

> "Would a developer cause a **silent failure** by not knowing this,
> AND is this NOT derivable from reading entry point files in <30 seconds?"

Both yes → record. Either no → omit.

## What Goes Here

- Implicit contracts between modules
- Non-obvious coupling (change A → must change B)
- Extension patterns (how to add new features)
- Silent-failure footguns
- Technical debt with real impact

## What Does NOT Go Here

- Type/struct field listings
- Function signatures
- API route enumerations
- "Module X does Y" descriptions
- Anything already in `_index.md`

## File Structure

```
mental-model/
  overview.md       — project-wide patterns, module graph
  <domain>.md       — per-domain knowledge (60-120 lines each)
```

## Template

```markdown
# [Domain Name]

## Entry Points
2-3 key files to start reading.

## Module Contracts
- "[A] guarantees [X] to [B]"

## Coupling
- A ↔ B: [mechanism]

## Extension Points
- Add new [X]: files to touch + pitfalls

## Common Mistakes
- Forgetting [Y] → [silent failure]

## Technical Debt
- [Issue]: state, impact, improvement
```

Omit empty sections. Generate with `/rebuild-docs`.
