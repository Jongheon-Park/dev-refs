---
name: write-ticket
description: "CMD 1 — Planner. Create or edit a ticket."
argument-hint: "[topic for new, or path/stem to edit]"
---

# /write-ticket — $ARGUMENTS

**All documents must be written in English.** (AI reads and writes these.)

## Conventions

- **Path:** `docs/ai-docs/tickets/<status>/YYMMDD-<category>-<name>.md`
- **Categories:** `bug`, `feat`, `refactor`, `chore`, `research`
- **Status dirs:** `idea/` → `todo/` → `wip/` → `done/` (or `dropped/`)
- **Reference by stem only** (e.g., `260325-feat-login`), never full path.
- **Move tickets** with `git mv`. Stems don't change.

## New ticket template

```markdown
---
title: [Title]
created: YYYY-MM-DD
---

# [Title]

## Problem / Goal
[What and why.]

## Scope
[In scope / out of scope.]

## Notes
[Context, related tickets.]
```

## Editing
- By stem → search `docs/ai-docs/tickets/*/`
- Append `### Result (<short-hash>) — YY-MM-DD` after completing work.
- Add `started: YYYY-MM-DD` on move to `wip/`, `completed:` on move to `done/`.
