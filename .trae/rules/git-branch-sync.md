# git-branch-sync — Git Branch Sync

## What it does
Sync your current feature branch with `main` (or any target branch). For team collaboration — when a teammate merges to `main` and you need those changes.

## Usage
```bash
# Sync with main (default)
bash /d/User/Desktop/GithubProject/skill/git-branch-sync/git-sync-branch.sh

# Sync with a specific branch
bash /d/User/Desktop/GithubProject/skill/git-branch-sync/git-sync-branch.sh develop
```

## Pipeline
1. **Handle uncommitted changes** — interactive: auto-commit(1) / custom commit(2) / stash(3) / abort(4)
2. **Switch & pull** — `git checkout main && git pull origin main`
3. **Merge back** — `git checkout bb && git merge main`
4. **Restore stash** — auto `git stash pop` after successful merge

## Conflict resolution
Script stops with a list of conflicted files:
```bash
# After editing conflicted files:
git add <file>
git commit
```

## Team scenario
- Dev A on `aa` → merges to `main`
- Dev B on `bb` → runs script → pulls A's code automatically
- Same-file conflicts → manual resolution
