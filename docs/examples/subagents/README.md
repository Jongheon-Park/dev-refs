# Subagent Examples — Phase Wrappers (Path B)

These are **example subagent definitions** for users who want model-isolated
dispatch per workflow phase. They are NOT installed by default — copy to
`.claude/agents/` if you want them.

## When to use

Path B (subagents) is most useful when:

- You're on **Max or higher billing tier** — token overhead from subagent
  context loading is acceptable
- You want **automated model selection** per phase (no manual `/model` switching)
- You prefer **explicit dispatch** (`@planner ...`) over slash command + model toggle

For most users on Pro or pay-per-token plans, **Path A** (slash commands
`/plan`, `/implement`, `/test`) is more efficient. The default kit ships with
Path A. Stick with `skills/`.

## What's here

| File | Phase | Model | Wraps |
|:---|:---|:---|:---|
| `planner.md` | 1 — Plan | Opus | `skills/plan.md` |
| `coder.md` | 2 — Code | Sonnet | `skills/implement.md` |
| `tester.md` | 3 — Test | Sonnet | `skills/test.md` |

Each is a thin wrapper: the subagent loads, reads the corresponding skill file,
and follows that workflow with its own model + tool restrictions.

## Install

```bash
# Copy all three to your project's .claude/agents/
cp docs/examples/subagents/*.md .claude/agents/

# Or copy individually
cp docs/examples/subagents/planner.md .claude/agents/
```

After install, dispatch from main conversation:

```
@planner Design a feature for X
@coder Implement ticket 260408-feat-foo
@tester Verify ticket 260408-feat-foo
```

## Customize

Each example is a starting point. Adjust:

- `model:` — switch to a different tier
- `tools:` — restrict or expand allowed tools
- Body — change instructions, add project-specific rules

## See also

- `skills/plan.md`, `skills/implement.md`, `skills/test.md` — underlying workflows
- `agents/explorer.md` — read-only Haiku helper (active by default)
- Main `README.md` — primary Path A workflow
