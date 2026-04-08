#!/bin/bash
# setup.sh — Deploy or update dev-refs for a project
# Usage:
#   bash /path/to/dev-refs/setup.sh <project-root>            # initial setup (symlink, default)
#   bash /path/to/dev-refs/setup.sh <project-root> --copy     # initial setup (copy mode, Windows fallback)
#   bash /path/to/dev-refs/setup.sh <project-root> --update   # refresh kit-owned files in existing project

set -e

# === Argument parsing ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

PROJECT_ROOT=""
MODE="symlink"
UPDATE_MODE=false

for arg in "$@"; do
  case "$arg" in
    --copy) MODE="copy" ;;
    --update) UPDATE_MODE=true ;;
    --*) echo "[ERROR] Unknown flag: $arg"; exit 1 ;;
    *)
      if [ -z "$PROJECT_ROOT" ]; then
        PROJECT_ROOT="$arg"
      else
        echo "[ERROR] Unexpected argument: $arg"
        exit 1
      fi
      ;;
  esac
done

if [ -z "$PROJECT_ROOT" ]; then
  echo "Usage: bash setup.sh <project-root> [--copy|--update]"
  echo "  (no flag) Initial setup, symlink mode (default)"
  echo "  --copy    Initial setup, copy mode (Windows fallback)"
  echo "  --update  Refresh kit-owned files in existing project"
  echo ""
  echo "Example: bash setup.sh D:/my-project"
  echo "         bash setup.sh D:/my-project --update"
  exit 1
fi

# Validate target directory exists
if [ ! -d "$PROJECT_ROOT" ]; then
  echo "[ERROR] Target directory does not exist: $PROJECT_ROOT"
  exit 1
fi

# Resolve to absolute path
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"

# Validate source files exist
MISSING=0
for src in "rules.md" "discovery.md" "agents" "docs/ai-docs" "docs/profiles" "skills" ".claude/settings.json"; do
  if [ ! -e "$SCRIPT_DIR/$src" ]; then
    echo "[ERROR] Source not found: $SCRIPT_DIR/$src"
    MISSING=1
  fi
done
if [ "$MISSING" -eq 1 ]; then
  echo "Aborting: missing source files."
  exit 1
fi

# === Helper functions ===

# Create symlink with fallback to copy on Windows
safe_link() {
  local src="$1" dst="$2"
  if ln -s "$src" "$dst" 2>/dev/null; then
    return 0
  else
    echo "[WARN] Symlink failed, falling back to copy"
    if [ -d "$src" ]; then
      cp -r "$src" "$dst"
    else
      cp "$src" "$dst"
    fi
    return 0
  fi
}

# Refresh a kit-owned path in update mode.
# - If destination is a symlink: verify, fix if broken
# - If destination is a copy (regular file/dir): overwrite contents
# - If destination is missing: create (symlink)
# Args: src dst name [is_dir]
#   is_dir = "yes" for directories, "no" for files (default: no)
refresh_path() {
  local src="$1" dst="$2" name="$3" is_dir="${4:-no}"
  if [ -L "$dst" ]; then
    if [ -e "$dst" ]; then
      echo "[OK] $name (symlink, auto-updated)"
    else
      rm "$dst"
      safe_link "$src" "$dst"
      echo "[FIX] $name (broken symlink → re-created)"
    fi
  elif [ "$is_dir" = "yes" ] && [ -d "$dst" ]; then
    # Directory copy mode — refresh .md files
    local count=0
    for f in "$src"/*.md; do
      [ -f "$f" ] || continue
      cp -f "$f" "$dst/"
      count=$((count + 1))
    done
    echo "[UPDATE] $name ($count files refreshed)"
  elif [ "$is_dir" = "no" ] && [ -f "$dst" ]; then
    cp -f "$src" "$dst"
    echo "[UPDATE] $name"
  else
    safe_link "$src" "$dst"
    echo "[NEW] $name"
  fi
}

# === Update mode ===
if [ "$UPDATE_MODE" = true ]; then
  VERSION=$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null || echo "unknown")
  echo "=== dev-refs update (V$VERSION) ==="
  echo "Source:  $SCRIPT_DIR"
  echo "Target:  $PROJECT_ROOT"
  echo ""

  if [ ! -d "$PROJECT_ROOT/.claude" ]; then
    echo "[ERROR] No .claude/ directory found in target."
    echo "        Run setup.sh without --update first to initialize."
    exit 1
  fi

  refresh_path "$SCRIPT_DIR/rules.md"      "$PROJECT_ROOT/.claude/CLAUDE.md"    ".claude/CLAUDE.md"    no
  refresh_path "$SCRIPT_DIR/discovery.md"  "$PROJECT_ROOT/.claude/discovery.md" ".claude/discovery.md" no
  refresh_path "$SCRIPT_DIR/agents"        "$PROJECT_ROOT/.claude/agents"       ".claude/agents/"      yes
  refresh_path "$SCRIPT_DIR/skills"        "$PROJECT_ROOT/.claude/commands"     ".claude/commands/"    yes

  # .claude/settings.json — always copied (never symlinked, per-project)
  SETTINGS_SOURCE="$SCRIPT_DIR/.claude/settings.json"
  SETTINGS_DEST="$PROJECT_ROOT/.claude/settings.json"
  if [ ! -f "$SETTINGS_DEST" ]; then
    cp "$SETTINGS_SOURCE" "$SETTINGS_DEST"
    echo "[NEW] .claude/settings.json (SessionStart hook installed)"
  elif diff -q "$SETTINGS_SOURCE" "$SETTINGS_DEST" >/dev/null 2>&1; then
    echo "[OK] .claude/settings.json (matches kit version)"
  else
    echo "[DIFF] .claude/settings.json differs from kit version"
    echo "       Manual review: diff $SETTINGS_SOURCE $SETTINGS_DEST"
  fi

  echo ""
  echo "User-owned files (not touched):"
  echo "  - CLAUDE.md             (project data)"
  echo "  - docs/profiles/        (stack-specific rules)"
  echo "  - docs/ai-docs/         (project state, tickets, deps, mental-model)"
  echo ""
  echo "=== Update complete (V$VERSION) ==="
  echo ""
  echo "Optional cleanup of pre-V1.3 artifacts (run manually if needed):"
  echo "  rm -rf $PROJECT_ROOT/docs/_legacy/"
  echo "  rm $PROJECT_ROOT/docs/profiles/cpp-*.md"

  exit 0
fi

# === Initial install ===
echo "=== dev-refs setup ==="
echo "Source:  $SCRIPT_DIR"
echo "Target:  $PROJECT_ROOT"
echo ""

# 1. Copy CLAUDE.md (skip if already exists)
if [ -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  echo "[SKIP] CLAUDE.md already exists (project data preserved)"
else
  cp "$SCRIPT_DIR/CLAUDE.md" "$PROJECT_ROOT/CLAUDE.md"
  echo "[COPY] CLAUDE.md"
fi

# 2. Copy docs/ (ai-docs, profiles)
mkdir -p "$PROJECT_ROOT/docs"

if [ -d "$PROJECT_ROOT/docs/ai-docs" ]; then
  echo "[SKIP] docs/ai-docs/ already exists"
else
  cp -r "$SCRIPT_DIR/docs/ai-docs" "$PROJECT_ROOT/docs/ai-docs"
  echo "[COPY] docs/ai-docs/"
fi

if [ -d "$PROJECT_ROOT/docs/profiles" ]; then
  echo "[SKIP] docs/profiles/ already exists"
else
  cp -r "$SCRIPT_DIR/docs/profiles" "$PROJECT_ROOT/docs/profiles"
  echo "[COPY] docs/profiles/"
fi

# Ensure all required ai-docs subdirectories exist (idempotent)
for dir in \
  "docs/ai-docs/_trash" \
  "docs/ai-docs/tickets/todo" \
  "docs/ai-docs/tickets/wip" \
  "docs/ai-docs/tickets/done" \
  "docs/ai-docs/tickets/dropped" \
  "docs/ai-docs/tickets/idea" \
  "docs/ai-docs/deps" \
  "docs/ai-docs/diagrams" \
  "docs/ai-docs/mental-model"; do
  full="$PROJECT_ROOT/$dir"
  mkdir -p "$full"
  touch "$full/.gitkeep"
done
echo "[OK] docs/ai-docs/ subdirectories verified"

# Ensure docs/ai-docs/_status.md exists (required by SessionStart hook)
STATUS_FILE="$PROJECT_ROOT/docs/ai-docs/_status.md"
if [ ! -f "$STATUS_FILE" ]; then
  cp "$SCRIPT_DIR/docs/ai-docs/_status.md" "$STATUS_FILE"
  echo "[COPY] docs/ai-docs/_status.md (template)"
else
  echo "[SKIP] docs/ai-docs/_status.md already exists"
fi

# 3. rules.md → .claude/CLAUDE.md
mkdir -p "$PROJECT_ROOT/.claude"
RULES_SOURCE="$SCRIPT_DIR/rules.md"

if [ -L "$PROJECT_ROOT/.claude/CLAUDE.md" ] || [ -f "$PROJECT_ROOT/.claude/CLAUDE.md" ]; then
  echo "[SKIP] .claude/CLAUDE.md already exists"
elif [ "$MODE" = "copy" ]; then
  cp "$RULES_SOURCE" "$PROJECT_ROOT/.claude/CLAUDE.md"
  echo "[COPY] .claude/CLAUDE.md (test mode)"
else
  safe_link "$RULES_SOURCE" "$PROJECT_ROOT/.claude/CLAUDE.md"
  echo "[LINK] .claude/CLAUDE.md → $RULES_SOURCE"
fi

# 4. discovery.md → .claude/discovery.md
DISCOVERY_SOURCE="$SCRIPT_DIR/discovery.md"

if [ -L "$PROJECT_ROOT/.claude/discovery.md" ] || [ -f "$PROJECT_ROOT/.claude/discovery.md" ]; then
  echo "[SKIP] .claude/discovery.md already exists"
elif [ "$MODE" = "copy" ]; then
  cp "$DISCOVERY_SOURCE" "$PROJECT_ROOT/.claude/discovery.md"
  echo "[COPY] .claude/discovery.md (test mode)"
else
  safe_link "$DISCOVERY_SOURCE" "$PROJECT_ROOT/.claude/discovery.md"
  echo "[LINK] .claude/discovery.md → $DISCOVERY_SOURCE"
fi

# 5. agents/ → .claude/agents/
AGENTS_SOURCE="$SCRIPT_DIR/agents"

if [ -L "$PROJECT_ROOT/.claude/agents" ] || [ -d "$PROJECT_ROOT/.claude/agents" ]; then
  echo "[SKIP] .claude/agents already exists"
elif [ "$MODE" = "copy" ]; then
  cp -r "$AGENTS_SOURCE" "$PROJECT_ROOT/.claude/agents"
  echo "[COPY] .claude/agents/ (test mode)"
else
  safe_link "$AGENTS_SOURCE" "$PROJECT_ROOT/.claude/agents"
  echo "[LINK] .claude/agents/ → $AGENTS_SOURCE"
fi

# 6. skills/ → .claude/commands/
SKILLS_SOURCE="$SCRIPT_DIR/skills"

if [ -L "$PROJECT_ROOT/.claude/commands" ] || [ -d "$PROJECT_ROOT/.claude/commands" ]; then
  echo "[SKIP] .claude/commands already exists"
elif [ "$MODE" = "copy" ]; then
  cp -r "$SKILLS_SOURCE" "$PROJECT_ROOT/.claude/commands"
  echo "[COPY] .claude/commands/ (test mode)"
else
  safe_link "$SKILLS_SOURCE" "$PROJECT_ROOT/.claude/commands"
  echo "[LINK] .claude/commands/ → $SKILLS_SOURCE"
fi

# 7. .claude/settings.json (SessionStart hook for _status.md auto-load)
# Always copy (never symlink) — settings.json is per-project, not shared.
SETTINGS_SOURCE="$SCRIPT_DIR/.claude/settings.json"

if [ -f "$PROJECT_ROOT/.claude/settings.json" ]; then
  echo "[SKIP] .claude/settings.json already exists (project settings preserved)"
else
  cp "$SETTINGS_SOURCE" "$PROJECT_ROOT/.claude/settings.json"
  echo "[COPY] .claude/settings.json (SessionStart hook)"
fi

echo "=== Done ($MODE mode) ==="
echo "Project structure:"
echo "  $PROJECT_ROOT/"
echo "  ├── CLAUDE.md              (project data)"
echo "  ├── .claude/"
echo "  │   ├── CLAUDE.md          → rules.md"
echo "  │   ├── discovery.md       → discovery.md"
echo "  │   ├── agents/            → agents/"
echo "  │   ├── commands/          → skills/"
echo "  │   └── settings.json      (SessionStart hook)"
echo "  └── docs/"
echo "      ├── ai-docs/"
echo "      │   └── _status.md     (auto-loaded each session)"
echo "      └── profiles/"
