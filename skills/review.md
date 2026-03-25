---
name: review
description: "CMD 2 — Coder. Code review. Find bugs, not compliments."
argument-hint: "[file, branch, or commit range]"
---

# /review — $ARGUMENTS

**All documents must be written in English.** (AI reads and writes these.)

**All code is suspect. No praise without reason.**

## Scope
- File path → review that file
- Branch → `git diff main...<branch>`
- No argument → `git diff` + `git diff --cached`

## Check these
1. **Correctness** — Does it work? Edge cases? Error handling?
2. **Style** — Matches existing codebase patterns?
3. **Security** — Injection, hardcoded secrets, unsafe input?
4. **Tests** — New code paths covered?

## Save Report

Save to `docs/ai-docs/tickets/wip/YYMMDD-review-report-<stem>.md`:

```markdown
---
title: "Review Report: <scope>"
created: YYYY-MM-DD
ticket: <ticket-stem or "none">
---

# Review Report: <scope>

## Critical (must fix)
- `file:line` — [issue]. Fix: [suggestion]

## Important (should fix)
- `file:line` — [issue]. Fix: [suggestion]

## Minor (nice to fix)
- `file:line` — [issue]

## Verdict
Approve / Request changes / Needs discussion

## Summary
- Files reviewed: N
- Critical: N | Important: N | Minor: N
```

Tell user: "Review report saved. CMD 2 should address Critical/Important items."
