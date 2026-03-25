---
name: rebuild-docs
description: "CMD 3 — Tester. Regenerate project documentation from current source."
argument-hint: "[specific area, 'mental-model', or blank for full rebuild]"
---

# /rebuild-docs — $ARGUMENTS

**All documents must be written in English.** (AI reads and writes these.)

Scan the project and update documentation.

## Part 1: _index.md

1. **Scan project structure.** Walk directories, identify modules, entry points.
2. **Detect tech stack.** Check for `.sln`, `CMakeLists.txt`, `package.json`, etc.
3. **Read existing docs.** Compare `_index.md` against actual project state.
4. **Update `_index.md`.** Fix stale info:
   - Operational state, directory map, key files
   - Build/test commands, module descriptions
5. **Update diagrams** in `docs/ai-docs/diagrams/` if structure changed.
6. **Check profiles.** Verify `docs/profiles/*.md` selection still matches stack.

## Part 2: mental-model/

7. **Check existing mental-model docs** against current source.
8. **For each project domain**, apply the inclusion test:
   > "Silent failure if unknown? AND not derivable from source in <30s?"
9. **Create or update** domain files in `docs/ai-docs/mental-model/`:
   - Entry Points, Module Contracts, Coupling
   - Extension Points, Common Mistakes, Technical Debt
   - Omit empty sections. Target 60-120 lines per domain.
10. **Remove** docs for domains that no longer exist.
11. **Verify** — grep file paths and function names to confirm they still exist.

## Report

```markdown
## Rebuild Summary
- _index.md: [what changed]
- mental-model/: [created / updated / removed files]
- Stale items: [needs manual review]
```

Only update what actually changed. Don't rewrite for the sake of rewriting.
