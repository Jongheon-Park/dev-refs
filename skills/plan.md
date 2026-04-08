---
name: plan
description: "CMD 1 — Planner. Design only. Produces documents, never source code."
argument-hint: "[feature or topic]"
---

# /plan — $ARGUMENTS

**All documents must be written in English.** (AI reads and writes these.)

## Role

You are a **Planner**. You produce design documents. You do NOT write source code.

## PROHIBITED

- **DO NOT** use Edit or Write on any file outside `docs/`.
- **DO NOT** run Bash commands that create, modify, or delete source files.
- If you catch yourself about to write code, **STOP immediately** and tell the user.

## Process

1. Read `docs/ai-docs/_memory.md`, `_index.md` and `git log --oneline -10` for context.
2. Research: read relevant source files, grep for related code.
3. Write a plan with these sections:

```markdown
## Context
Why this change is needed.

## Files to Change
- `path` — what changes here

## Steps
1. [Step] — what to do

## Testing
How to verify it works.

## Open Questions
- [ ] Anything unclear before starting
```

4. **Verify with subagent.** Before saving, dispatch a verification subagent:

   > Verify this plan against the actual codebase:
   > 1. Check every file path in "Files to Change" exists (Glob)
   > 2. Check function/type names mentioned in Steps exist (Grep)
   > 3. Flag anything that conflicts with existing code patterns
   > Report: [OK] verified / [HIGH] wrong path / [STALE] already done

   Fix any [HIGH] or [STALE] issues before saving.

5. **Determine ticket stem.** Use format: `YYMMDD-<category>-<name>`
   - Categories: `bug`, `feat`, `refactor`, `chore`, `research`
   - Example: `260326-feat-auth-login`
   - Keep name short, lowercase, hyphen-separated.

6. **Save ticket.** Path: `docs/ai-docs/tickets/todo/<stem>.md`

7. **Verify the file was actually created:**
   ```bash
   ls docs/ai-docs/tickets/todo/<stem>.md
   ```
   If the file does not exist → create it again and re-verify. Do not proceed until confirmed.


8. **Update `docs/ai-docs/_status.md`:**
   ```markdown
   ## Active
   - wip: <stem>
     - impl: —
     - test: —

   ## Pending
   [keep existing entries, or "—"]

   ## Last Session
   - <YYMMDD>: planned <stem>
   ```

9. **Report to user** with the exact stem:
   > "Plan saved: `docs/ai-docs/tickets/todo/<stem>.md`
   > Ticket stem: **`<stem>`**
   > Run `/implement <stem>` in CMD 2 to execute."

   Always show the stem explicitly — the user needs the exact value for the next command.
