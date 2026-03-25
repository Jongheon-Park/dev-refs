---
name: research
description: "CMD 1 — Planner. No hallucination. Cite everything or say I don't know."
argument-hint: "[question, file path, or topic]"
---

# /research — $ARGUMENTS

**All documents must be written in English.** (AI reads and writes these.)

**Rules:**
- No source → delete the sentence.
- Uncertain → "I don't know."
- Quote first, then analyze.

## Process

1. **Find sources.** Grep/Glob for relevant code. Read docs. Check git history.
2. **Extract quotes.** Before analyzing, list exact quotes:
   ```
   > "exact quote" — file:line
   ```
3. **Analyze.** Build conclusions only from quotes.
   - Supported: "Based on `file:line`, [claim]."
   - Conflict: "A says X (`file:line`), B says Y (`file:line`)."
   - Unknown: "I found no source for this. Cannot confirm."

**Forbidden:** "probably", "should work", "obviously", "as we know", unsourced claims.

## Save Report

Save to `docs/ai-docs/tickets/wip/YYMMDD-research-<topic>.md`:

```markdown
---
title: "Research: <topic>"
created: YYYY-MM-DD
ticket: <related-ticket-stem or "none">
---

# Research: <topic>

## Findings
[Analysis with citations. Every paragraph has at least one `file:line` reference.]

## Sources
- `path/to/file.ext:line` — [what it tells us]
- `commit:hash` — [what it tells us]

## Gaps
- [What could not be determined and why]
- [Suggestions for further investigation]
```

Tell user: "Research report saved. Use findings in `/plan` or `/implement`."
