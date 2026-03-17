# Profile: C++ / MFC

## Threading Rules

- **NO direct UI access from worker threads.**
- Use `PostMessage()` (async) or `SendMessage()` (sync) for UI updates.
- Protect shared resources with `CCriticalSection` or `std::mutex`.
- Thread-safe queues for producer-consumer patterns.
- Event objects (`CEvent`, `HANDLE`) for thread signaling.

## Memory Management

- **RAII mandatory.** Acquire in constructor, release in destructor.
- **Rule of Five.** If you define any of destructor / copy ctor / copy assign /
  move ctor / move assign, define all five (or `= delete` the ones you don't need).
- **Smart pointers over raw.** `std::unique_ptr` for sole ownership,
  `std::shared_ptr` for shared. Avoid `new`/`delete`.
- **`cv::Mat` is ref-counted** — use `.clone()` when independent copy is needed.

## MFC Patterns

- Dialog classes: `*Dlg.cpp` / `*Dlg.h`
- View classes: `*View.cpp` — MFC Doc/View architecture
- Main frame: `MainFrm.cpp`
- Message handlers: `ON_MESSAGE`, `ON_COMMAND`, `ON_BN_CLICKED`
- Custom messages: `#define WM_USER_xxx (WM_USER + N)`

## Code Style (C++14+)

**Prefer:**
- `auto`, `constexpr`, `nullptr`, `override`, `final`
- `std::make_unique`, `std::make_shared`
- `= default`, `= delete`
- `enum class`, range-based for

**Avoid:**
- `new`/`delete` (use smart pointers)
- C-style casts (use `static_cast`, `reinterpret_cast`)
- `NULL` (use `nullptr`)
- `typedef` (use `using`)

## Exception Safety

| Guarantee | Where |
|:---|:---|
| **No-throw** | Destructors, move operations (`noexcept`) |
| **Strong** | Public API functions (rollback on failure) |
| **Basic** | Internal helpers (valid state after failure) |

## Build Notes

- IDE: Visual Studio (MSBuild)
- Solution: `[name].sln`
- Preprocessor (Debug): `_DEBUG`, `_CONSOLE`, `_UNICODE`
- Preprocessor (Release): `NDEBUG`, `_CONSOLE`, `_UNICODE`

## Header Modification Protocol

Before modifying any header file:
1. Identify all `.vcxproj` files that include it.
2. Identify all `.cpp` files that `#include` it.
3. Report potential impact to user.
4. Get approval before modifying.

## Solution Analysis (Large Projects)

When analyzing a multi-project Visual Studio solution:
1. Parse `.sln` first — inventory all projects.
2. Analyze one project at a time, in dependency order (leaf → root).
3. Extract metadata from `.vcxproj`: output type, dependencies, source files.
4. Cite `file:line` for all findings.
