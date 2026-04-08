# Tech-Stack Profiles

This directory holds **stack-specific rules** for your project — supplements to the
universal `CLAUDE.md`. It ships **empty**: profiles are created on demand during
**Project Discovery** based on the detected stack, or written manually when needed.

## Auto-Generation (Discovery)

During discovery, if no profile in this directory matches the detected stack,
the AI creates one automatically.

1. **Detect stack** from project files (`package.json`, `Cargo.toml`, `*.sln`, etc.)
2. **Create `profiles/<language>-<framework>.md`** with:
   - Language-specific invariants (memory model, type system, etc.)
   - Framework-specific patterns and anti-patterns
   - Build/test commands for the stack
   - Threading/concurrency model if applicable
   - Common pitfalls specific to the ecosystem
3. **Present to user** for review before using.
4. **Keep under 80 lines.** Only rules that differ from the universal `CLAUDE.md`.

## Profile Template

```markdown
# Profile: [Language] / [Framework]

## [Category 1 — e.g. Memory/Type/Concurrency Rules]
- Rule 1
- Rule 2

## [Category 2 — e.g. Framework Patterns]
**Prefer:**
- Pattern 1
**Avoid:**
- Anti-pattern 1

## Build Notes
- Build: `[command]`
- Test: `[command]`
- Lint: `[command]`
```

## Naming Convention

`<language>-<framework>.md` — all lowercase, hyphen-separated.

Examples:
- `python-fastapi.md`
- `typescript-react.md`
- `rust-tokio.md`
- `csharp-wpf.md`
- `go-gin.md`
- `cpp-mfc.md`
