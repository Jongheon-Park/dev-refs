---
name: document-dependency
description: "Document an external library's API to prevent hallucination."
argument-hint: "[package name]"
---

# /document-dependency — $ARGUMENTS

**All documents must be written in English.** (AI reads and writes these.)

When AI training knowledge differs from actual API, document the truth.

1. **Dump what you think you know** about the package's API.
2. **Find actual source.**
   - C++: project includes, vcpkg/conan packages
   - Python: `site-packages/` or venv
   - Node: `node_modules/`
   - Rust: `~/.cargo/registry/src/`
3. **Compare** your knowledge against real source. Note differences:
   - Wrong signatures
   - Renamed/removed types
   - Changed defaults
   - Missing parameters
4. **Write** to `docs/ai-docs/deps/<package>[v<version>].md`:
   - Corrections (what you got wrong)
   - Key API surface (real signatures)
   - Gotchas (non-obvious behavior)
5. **Report** what was documented and what's uncertain.

Read this file before writing code that uses the package.
