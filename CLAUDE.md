# git-branch-sync — Git Branch Sync Skill

Sync your current feature branch with `main` (or any target branch) in one shot.

## Before using — ALWAYS ask (in Chinese, one at a time)

Ask questions one by one, wait for the user's reply before asking the next:

1. "你当前在哪个分支？"
2. After reply → "要跟哪个分支同步？默认 main"

## Usage

```bash
# Default: sync with main
bash git-sync-branch.sh

# Sync with a specific branch
bash git-sync-branch.sh develop

# If Git alias is configured
git sync-branch
```

## Pipeline

1. **Handle uncommitted changes** — prompted interactively: auto-commit(1) / custom commit(2) / stash(3) / abort(4)
2. **Switch & pull** — `git checkout main && git pull origin main`
3. **Merge back** — `git checkout bb && git merge main`
   - Success → restore stash (if chosen), done
   - Conflict → list conflicting files, guide manual resolution
4. **Restore stash** — auto `git stash pop` after successful merge

## Conflict resolution

```bash
# After editing conflicted files:
git add <file>
git commit
```

## Collaboration scenario

- Dev A works on `aa` branch → merges to `main`
- Dev B works on `bb` branch → runs this script → pulls A's changes automatically
- Same-file conflicts are surfaced for manual resolution
