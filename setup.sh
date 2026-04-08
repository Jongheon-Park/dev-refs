#!/bin/bash
# setup.sh — Deploy dev-refs to a project
# Usage: bash /path/to/dev-refs/setup.sh <project-root>

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$1"

MODE="symlink"
if [ "${2:-}" = "--copy" ]; then
  MODE="copy"
fi

if [ -z "$PROJECT_ROOT" ]; then
  echo "Usage: bash setup.sh <project-root>"
  echo "Example: bash setup.sh D:/my-project"
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

# Helper: create symlink with fallback to copy on Windows
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