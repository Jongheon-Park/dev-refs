# Tech-Stack Profiles

Each file contains stack-specific rules that supplement the universal `CLAUDE.md`.

## Usage

1. Copy `CLAUDE.md` + `ai-docs/` into your project root.
2. Copy the relevant profile(s) into `profiles/` in your project.
3. Add a reference in `CLAUDE.md` under **Architecture Rules**:
   ```markdown
   Tech-specific rules: see `profiles/<stack>.md`
   ```

## Available Profiles

| Profile | When to use |
|:---|:---|
| `cpp-mfc.md` | C++/MFC Windows desktop applications |
| `cpp-imgui.md` | C/C++ projects using Dear ImGui (immediate mode GUI) |
| `cpp-opencv.md` | C++ projects using OpenCV for vision processing |

## Creating New Profiles

During **Project Discovery**, if no existing profile matches the detected
tech stack, the AI **creates a new profile automatically**.

### Auto-Generation Rules

1. **Detect stack** from project files (package.json, Cargo.toml, etc.)
2. **Create `profiles/<language>-<framework>.md`** with:
   - Language-specific invariants (memory model, type system, etc.)
   - Framework-specific patterns and anti-patterns
   - Build/test commands for the stack
   - Threading/concurrency model if applicable
   - Common pitfalls specific to the ecosystem
3. **Present to user** for review before using.
4. **Keep under 80 lines.** Only rules that differ from universal CLAUDE.md.

### Profile Template

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

### Naming Convention

`<language>-<framework>.md` — all lowercase, hyphen-separated.

Examples:
- `python-fastapi.md`
- `typescript-react.md`
- `rust-tokio.md`
- `csharp-wpf.md`
- `go-gin.md`
