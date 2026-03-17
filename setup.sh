#!/bin/bash
# setup.sh — Deploy dev-refs to a project
# Usage: bash /path/to/dev-refs/setup.sh <project-root>

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$1"

if [ -z "$PROJECT_ROOT" ]; then
  echo "Usage: bash setup.sh <project-root>"
  echo "Example: bash setup.sh D:/my-project"
  exit 1
fi

# Resolve to absolute path
PROJECT_ROOT="$(cd "$PROJECT_ROOT" 2>/dev/null && pwd || echo "$PROJECT_ROOT")"

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

# 3. Symlink rules.md → .claude/CLAUDE.md
mkdir -p "$PROJECT_ROOT/.claude"
RULES_SOURCE="$SCRIPT_DIR/rules.md"

if [ -L "$PROJECT_ROOT/.claude/CLAUDE.md" ]; then
  echo "[SKIP] .claude/CLAUDE.md symlink already exists"
elif [ -f "$PROJECT_ROOT/.claude/CLAUDE.md" ]; then
  echo "[WARN] .claude/CLAUDE.md exists as a regular file. Remove it first to use symlink."
else
  ln -s "$RULES_SOURCE" "$PROJECT_ROOT/.claude/CLAUDE.md"
  echo "[LINK] .claude/CLAUDE.md → $RULES_SOURCE"
fi

echo ""
echo "=== Done ==="
echo "Project structure:"
echo "  $PROJECT_ROOT/"
echo "  ├── CLAUDE.md              (project data)"
echo "  ├── .claude/"
echo "  │   └── CLAUDE.md          → rules.md (symlink)"
echo "  └── docs/"
echo "      ├── ai-docs/"
echo "      └── profiles/"
