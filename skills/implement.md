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

Find ticket: stem → search `docs/ai-docs/tickets/*/`. Path → read directly.
**Do not proceed until you have read the plan document.**

## Phase 1: Verify Plan

1. **Load context.** Read the ticket. Read `docs/ai-docs/_memory.md` and `_index.md` if needed. `git log --oneline -10`.
2. **Verify plan with subagent.** Before coding, dispatch a verification subagent:

   > Verify this plan is still valid against current codebase:
   > 1. All file paths in "Files to Change" still exist
   > 2. No conflicting changes since plan was written (check git log)
   > 3. Functions/types referenced in Steps still exist
   > Report: [OK] / [HIGH] path gone / [STALE] already implemented / [CONFLICT] changed since plan

   - [OK] → proceed.
   - [HIGH] or [CONFLICT] → report to user, ask whether to proceed or re-plan.
   - [STALE] → report to user, skip already-done steps.

## Phase 2: Code

3. **Move ticket to `wip/`.** `git mv` from `todo/` to `wip/`.
4. **Check for test reports.** If `YYMMDD-test-report-<stem>.md` exists in `wip/`, read it and address failures.
5. **Break into tasks.** Use `TaskCreate` for each step from the plan.
6. **Execute.** Read target files before editing. Follow existing style.
   - 3 consecutive failures on same issue → stop and ask user.
7. **STOP.** Do NOT auto-commit. Say:
   > "Code complete. Run `/test <ticket-stem>` in CMD 3 to verify.
   > When ready, say **commit** or **report**."

## Phase 3: Commit (only when user says "commit" or "report")

**Do NOT proceed to this phase until the user explicitly commands it.**

8. **Security check.** Before committing, verify:
   - [ ] No hardcoded secrets, API keys, passwords in changed files
   - [ ] No credentials files staged (`.env`, `*.key`, `*.pem`, `credentials.json`)
   - [ ] No personal/company emails in code or git config
   - [ ] No internal IPs, server addresses, or endpoints exposed
   - [ ] No injection vulnerabilities (SQL, command, XSS) introduced
   - Run: `git diff --cached` and scan for patterns: `password`, `secret`, `api_key`, `token`, `Bearer`, hardcoded IPs
   - **If any issue found → STOP and report to user. Do NOT commit.**

9. **Commit.** Format:
   ```
   <type>(<scope>): <summary>

   ## AI Context
   - <why this approach>

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```

10. **Append completion report to ticket:**
    ```markdown
    ### Result (<short-hash>) — YY-MM-DD
    - What was implemented (summary of changes)
    - Deviations from plan (if any)
    - Security check: PASS
    - Remaining work or follow-up needed
    ```

11. **Update `_memory.md`.** Add entry to Recent Work. Update Pending if items resolved or new ones found.
