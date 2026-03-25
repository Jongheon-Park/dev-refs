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

# 3. Create mental-model directory
mkdir -p "$PROJECT_ROOT/docs/ai-docs/mental-model"
if [ ! -f "$PROJECT_ROOT/docs/ai-docs/mental-model/README.md" ]; then
  cp "$SCRIPT_DIR/docs/ai-docs/mental-model/README.md" \
     "$PROJECT_ROOT/docs/ai-docs/mental-model/README.md"
  echo "[COPY] docs/ai-docs/mental-model/README.md"
fi

# 4. Create ticket status directories
for status_dir in idea todo wip done dropped; do
  mkdir -p "$PROJECT_ROOT/docs/ai-docs/tickets/$status_dir"
  [ -f "$PROJECT_ROOT/docs/ai-docs/tickets/$status_dir/.gitkeep" ] || \
    touch "$PROJECT_ROOT/docs/ai-docs/tickets/$status_dir/.gitkeep"
done
echo "[DIRS] docs/ai-docs/tickets/{idea,todo,wip,done,dropped}/"

# 5. Copy skills → .claude/commands/
mkdir -p "$PROJECT_ROOT/.claude/commands"
for skill in "$SCRIPT_DIR/skills/"*.md; do
  [ -f "$skill" ] || continue
  name="$(basename "$skill")"
  if [ -f "$PROJECT_ROOT/.claude/commands/$name" ]; then
    echo "[SKIP] .claude/commands/$name already exists"
  else
    cp "$skill" "$PROJECT_ROOT/.claude/commands/$name"
    echo "[COPY] .claude/commands/$name"
  fi
done

# 6. Symlink rules.md → .claude/CLAUDE.md
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
echo "  │   ├── CLAUDE.md          → rules.md (symlink)"
echo "  │   └── commands/          (skills)"
echo "  └── docs/"
echo "      ├── ai-docs/"
echo "      │   ├── _memory.md           (session memory)"
echo "      │   ├── mental-model/        (operational knowledge)"
echo "      │   └── tickets/{idea,todo,wip,done,dropped}/"
echo "      └── profiles/"
