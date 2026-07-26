#!/bin/bash
#
# git-sync-branch — Git Branch Sync Skill
#
# Sync the current feature branch with main (or any target branch):
#   1. Save uncommitted changes (commit or stash)
#   2. Switch to target branch and git pull
#   3. Switch back to feature branch, git merge target
#   4. On conflict, list files and guide manual resolution
#
# Usage:
#   bash git-sync-branch.sh              # sync with main
#   bash git-sync-branch.sh develop      # sync with develop

set -e

# ── Colors ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ── Args ──
TARGET="${1:-main}"
CURRENT=$(git rev-parse --abbrev-ref HEAD)

if [ "$CURRENT" = "$TARGET" ]; then
  echo -e "${RED}Error: already on $TARGET branch, nothing to sync${NC}"
  exit 1
fi

echo -e "${BLUE}========================================"
echo "  Branch Sync: $CURRENT → $TARGET"
echo -e "========================================${NC}"

# ── Step 1: Handle uncommitted changes ──
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo ""
  echo -e "${YELLOW}▶ Uncommitted changes detected${NC}"

  git status --short

  echo ""
  echo "Choose how to handle:"
  echo "  1) git add . + auto-commit"
  echo "  2) Custom commit message"
  echo "  3) git stash (restore after merge)"
  echo "  4) Abort"
  read -p "Enter [1-4] (default 1): " choice

  case "${choice:-1}" in
    1)
      git add .
      git commit -m "chore: save WIP before syncing $CURRENT with $TARGET"
      echo -e "${GREEN}  ✓ Auto-committed${NC}"
      ;;
    2)
      git add .
      read -p "Enter commit message: " msg
      git commit -m "$msg"
      echo -e "${GREEN}  ✓ Committed${NC}"
      ;;
    3)
      git stash push -m "sync-branch-auto-stash $(date '+%Y-%m-%d %H:%M')"
      echo -e "${GREEN}  ✓ Stashed${NC}"
      STASHED=true
      ;;
    4)
      echo -e "${RED}  ✗ Aborted${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}  ✗ Invalid option${NC}"
      exit 1
      ;;
  esac
fi

# ── Step 2: Switch to target branch & pull ──
echo ""
echo -e "${BLUE}▶ [1/3] Switching to $TARGET and pulling latest...${NC}"
git checkout "$TARGET"
git pull origin "$TARGET"
echo -e "${GREEN}  ✓ $TARGET is up to date${NC}"

# ── Step 3: Switch back & merge target ──
echo ""
echo -e "${BLUE}▶ [2/3] Switching back to $CURRENT, merging $TARGET...${NC}"
git checkout "$CURRENT"
echo ""

if git merge "$TARGET"; then
  echo -e "${GREEN}  ✓ $TARGET merged into $CURRENT successfully${NC}"
else
  echo ""
  echo -e "${RED}⚠️  Merge conflict! Resolve manually:${NC}"
  echo "  1. Edit conflicted files"
  echo "  2. git add <file>"
  echo "  3. git commit"
  echo ""
  echo "  Conflicted files:"
  git diff --name-only --diff-filter=U | sed 's/^/    /'
  exit 1
fi

# ── Restore stash ──
if [ "$STASHED" = true ]; then
  echo ""
  echo -e "${BLUE}▶ [3/3] Restoring stash...${NC}"
  if git stash pop; then
    echo -e "${GREEN}  ✓ Stash restored${NC}"
  else
    echo -e "${RED}  ⚠️ Stash pop conflict, handle manually: git stash pop${NC}"
  fi
fi

echo ""
echo -e "${GREEN}========================================"
echo "  ✅ Sync complete! $CURRENT now includes $TARGET"
echo -e "========================================${NC}"
