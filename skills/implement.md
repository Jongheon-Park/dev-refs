---
name: implement
description: "CMD 2 — Coder. Execute a plan — write code, then wait for user to trigger commit."
argument-hint: "<ticket-stem or ticket-path> (REQUIRED)"
---

# /implement — $ARGUMENTS

**All documents must be written in English.** (AI reads and writes these.)

## Gate — ticket required

If no ticket argument given, **STOP**. Say:
> "A ticket is required. Run `/plan <feature>` in CMD 1 first, or specify a ticket stem."

### Finding the ticket

1. Search `docs/ai-docs/tickets/*/` for `<stem>.md`.
2. If not found → search all `docs/ai-docs/tickets/` recursively for any `.md` with the stem in filename.
3. If still not found → list all files in `tickets/todo/` and `tickets/wip/` and show user:
   > "Ticket `<stem>` not found. Available tickets:
   > - todo/: [list]
   > - wip/: [list]
   > Did you mean one of these? Or run `/plan <feature>` to create one."
4. **Legacy file detection:** If a file like `TASK_*.md`, `SPEC_*.md`, or similar exists in the project root or `docs/`, flag it:
   > "Found a possible legacy plan file: `<path>`. Should I treat this as the plan?
   > (It doesn't follow ticket conventions — stem will be assigned automatically.)"
   > Wait for user confirmation before proceeding.

**Do not proceed until the ticket file path is confirmed and its contents are read.**

## Phase 1: Verify Plan

1. **Load context.** Read the ticket. Read `docs/ai-docs/_memory.md` and `_index.md` if needed. `git log --oneline -10`.

2. **Check for failure report.** Look for `docs/ai-docs/tickets/wip/YYMMDD-test-report-<stem>.md`.
   - If found → read it before touching any code. Address every listed failure.
   - Note the `attempt:` number in the report header. If attempt ≥ 3 → **STOP and escalate:**
     > "3-strike limit reached. Same failures after 3 attempts.
     > Manual review or re-plan needed before continuing."

3. **Verify plan with subagent.** Before coding, dispatch a verification subagent:

   > Verify this plan is still valid against current codebase:
   > 1. All file paths in "Files to Change" still exist
   > 2. No conflicting changes since plan was written (check git log)
   > 3. Functions/types referenced in Steps still exist
   > Report: [OK] / [HIGH] path gone / [STALE] already implemented / [CONFLICT] changed since plan

   - [OK] → proceed.
   - [HIGH] or [CONFLICT] → report to user, ask whether to proceed or re-plan.
   - [STALE] → report to user, skip already-done steps.

## Phase 2: Code

4. **Move ticket to `wip/`.** `git mv` from `todo/` to `wip/` (skip if already there).
5. **Break into tasks.** Use `TaskCreate` for each step from the plan.
6. **Execute.** Read target files before editing. Follow existing style.
   - 3 consecutive failures on same issue → stop and ask user.

## Phase 3: Implementation Report (REQUIRED before stopping)

7. **Determine attempt number.**
   - First implementation: `attempt: 1`
   - Re-implementing after test failure: increment from the previous test report's attempt number.

8. **Write implementation report.** Save to `docs/ai-docs/tickets/wip/YYMMDD-impl-report-<stem>.md`:

   ```markdown
   ---
   title: "Implementation Report: <stem>"
   created: YYYY-MM-DD
   ticket: <stem>
   attempt: <N>
   ---

   # Implementation Report: <stem>

   ## What Was Done
   - [Summary of changes made, file by file]

   ## Deviations from Plan
   - [Anything done differently from the plan, and why]
   - "None" if fully followed.

   ## Edge Cases Excluded
   - [Anything intentionally not handled, with reason]

   ## Known Risks
   - [Anything that might break or needs careful testing]

   ## Files Changed
   - `path/to/file` — [what changed]
   ```

9. **Verify the report was saved:**
   ```bash
   ls docs/ai-docs/tickets/wip/
   ```
   Confirm the impl-report file appears in the listing.

10. **Update `_status.md`:**
    ```markdown
    ## Active
    - wip: <stem>
      - impl: done (attempt <N>)
      - test: —

    ## Pending
    [keep existing entries]

    ## Last Session
    - <YYMMDD>: implemented <stem> (attempt <N>)
    ```

11. **STOP.** Do NOT auto-commit. Say:
    > "Code complete (attempt <N>). Implementation report saved.
    > Run `/test <stem>` in CMD 3 to verify."

## Phase 4: Commit (only when user says "commit")

**Do NOT proceed to this phase until the user explicitly commands it.**

12. **Security check.** Before committing, verify:
    - [ ] No hardcoded secrets, API keys, passwords in changed files
    - [ ] No credentials files staged (`.env`, `*.key`, `*.pem`, `credentials.json`)
    - [ ] No personal/company emails in code or git config
    - [ ] No internal IPs, server addresses, or endpoints exposed
    - [ ] No injection vulnerabilities (SQL, command, XSS) introduced
    - Run: `git diff --cached` and scan for patterns: `password`, `secret`, `api_key`, `token`, `Bearer`, hardcoded IPs
    - **If any issue found → STOP and report to user. Do NOT commit.**

13. **Commit.** Format:
    ```
    <type>(<scope>): <summary>

    ## AI Context
    - <why this approach>
    - <deviations from plan, if any>

    Co-Authored-By: Claude <noreply@anthropic.com>
    ```

14. **Append completion report to ticket:**
    ```markdown
    ### Result (<short-hash>) — YY-MM-DD
    - What was implemented (summary of changes)
    - Deviations from plan (if any)
    - Security check: PASS
    - Remaining work or follow-up needed
    ```

15. **Update `_memory.md`.** Add entry to Recent Work. Update Pending if items resolved or new ones found.

16. **Clear `_status.md` Active section** (ticket is done):
    ```markdown
    ## Active
    - —

    ## Pending
    [keep or update]

    ## Last Session
    - <YYMMDD>: committed <stem> (<short-hash>)
    ```
