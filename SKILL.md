---
name: git-branch-sync
description: Git Branch Sync Skill — sync your current feature branch with main (or any target branch) in one shot. Automatically saves uncommitted changes, switches to the target branch, pulls latest, and merges back. Use when users ask "sync branch", "sync code", "merge main", "update feature branch", "pull latest from main", "同步分支", "同步代码", "帮我同步", "合并主分支", "拉取最新代码", or any branch-sync workflow in team collaboration.
---

# git-branch-sync — Git Branch Sync Skill

One-shot sync your current feature branch with `main` (or any target branch). Automates the full save-switch-pull-merge cycle with clear conflict guidance.

## Install

```bash
# 1. Clone
git clone <repo-url> git-branch-sync

# 2. Recommended: add a Git alias
git config --global alias.sync-branch '!bash /path/to/git-branch-sync/git-sync-branch.sh'

# 3. Done. Run anywhere:
git sync-branch
```

Pure bash. Zero dependencies.

## What the skill gives you

- **Automated 3-step sync** — save changes → switch & pull → merge back
- **4 handling strategies for uncommitted changes** — auto-commit / custom commit / stash / abort
- **Conflict detection & guidance** — lists conflicting files and resolution steps
- **Auto stash restore** — if you chose stash, it auto-pops after a successful merge
- **Any target branch** — defaults to `main`, also works with `develop`, `release`, etc.
- **Git alias integration** — feels like a native `git` subcommand

## When to use

Any team collaboration scenario where you need to pull someone else's changes from the base branch into your feature branch:

- **Team sync**: A merged to `main`, B needs those changes in `bb`
- **Pre-PR update**: before opening a PR, make sure your branch has the latest `main`
- **Long-lived branches**: periodically sync a long-running feature branch to reduce merge conflicts

## Before you use — ALWAYS ask

**Do not run the sync until you confirm two things with the user.**

1. **Current branch.** Which branch are they on? This is the branch that will receive the merged code.
   - If unsure, ask them to run `git branch` or `git rev-parse --abbrev-ref HEAD`.
2. **Target branch.** Which branch do they want to sync with? Default is `main`, but confirm:
   - Is it `main`, `develop`, `release`, or something else?
   - Does the target branch already contain the changes they need?

Ask one question at a time. First:

> 你当前在哪个分支？（运行 `git branch` 看一下）

After the user replies, then ask:

> 要跟哪个分支同步？默认是 `main`，还是其他的？

## Quick start

```bash
# On your feature branch, sync with main
bash git-sync-branch.sh

# Sync with a different target
bash git-sync-branch.sh develop

# With Git alias configured
git sync-branch
```

What happens:

1. Detects uncommitted changes, prompts for action (commit / stash / abort)
2. Auto-switches to `main` → `git pull`
3. Switches back to your feature branch → `git merge main`
4. Auto-restores stash if chosen
5. On conflict: lists files and resolution steps

## Pipeline

```
Current branch: feature/bb
Target branch:  main

┌──────────────────────────────────────────────────────┐
│  Step 1: Handle uncommitted changes                  │
│  ┌─────────────────────────────────────┐             │
│  │ Changes detected → pick 1/2/3/4     │             │
│  │ 1) auto-commit 2) custom commit     │             │
│  │ 3) stash 4) abort                   │             │
│  └─────────────────────────────────────┘             │
│                                                      │
│  Step 2: Switch to target branch & pull              │
│  ┌─────────────────────────────────────┐             │
│  │ git checkout main                   │             │
│  │ git pull origin main                │             │
│  └─────────────────────────────────────┘             │
│                                                      │
│  Step 3: Switch back & merge target                  │
│  ┌─────────────────────────────────────┐             │
│  │ git checkout feature/bb             │             │
│  │ git merge main                      │             │
│  │  → success: ✅ sync complete        │             │
│  │  → conflict: ⚠️ list files, guide   │             │
│  └─────────────────────────────────────┘             │
│                                                      │
│  Step 4 (optional): Restore stash                   │
│  ┌─────────────────────────────────────┐             │
│  │ git stash pop (auto after merge)    │             │
│  └─────────────────────────────────────┘             │
└──────────────────────────────────────────────────────┘
```

## Change handling strategies

When the script detects uncommitted changes:

| Option | Command | Best for |
|--------|---------|----------|
| **1 — Auto-commit** | `git add . && git commit -m "..."` | Changes are complete and ready |
| **2 — Custom commit** | Same, with your message | You want a meaningful commit message |
| **3 — Stash** | `git stash push -m "..."` | Work in progress, don't want to commit yet |
| **4 — Abort** | Exit | You want to handle it manually |

If you chose stash (#3), it auto-restores via `git stash pop` after a successful merge. If the pop itself causes conflicts (e.g., stashed changes conflict with the newly merged code), the script warns you:

```bash
# If auto-restore fails, do it manually:
git stash pop
# Resolve conflicts, then:
git add <file>
git commit
```

## Conflict resolution

Conflicts happen. The script stops and prints clear guidance:

```bash
⚠️  Merge conflict! Resolve manually:
  1. Edit conflicted files
  2. git add <file>
  3. git commit

  Conflicted files:
    src/index.ts
    src/config.ts
```

Resolution:

```bash
# 1. Open files, search for <<<<<<< markers
# 2. Keep the right code, remove conflict markers
# 3. Mark as resolved
git add src/index.ts src/config.ts
# 4. Complete the merge
git commit
```

## Best practices

- **Sync before starting**: run `git sync-branch` before beginning a new feature to ensure you're on a fresh base
- **Sync regularly**: for long-lived branches, sync daily or every few days to avoid conflict pileups
- **Commit often**: frequent small commits mean you can safely pick "auto-commit" without losing context
- **Stash before complex merges**: if you have messy WIP changes, stash them first — cleaner merge, cleaner recovery

## Team workflow example

```
main  ──●────────────────────●──────────
         ↘                  ↗
  aa ────●── A's feature ──●
                                   ↘
  bb ───────────────────────────────●── B's feature
                                         │
                                         ├── B works on bb
                                         ├── A finishes aa → merges to main
                                         └── B runs git sync-branch
                                              → pulls A's code into bb
```

## Multi-tool support

This skill works with all major AI coding tools:

| Tool | Mechanism | How to use |
|------|-----------|------------|
| **Claude Code** | `.claude/settings.json` registers `/sync-branch` command | "sync my branch" or `/sync-branch` |
| **Cursor** | `.cursor/rules/git-branch-sync.mdc` auto-injects context | AI reads the rule and calls the script |
| **Trae** | `.trae/rules/git-branch-sync.md` auto-injects context | Same as above |
| **Codex CLI** | Reads `CLAUDE.md` as project instructions | AI knows about the skill |
| **Any terminal** | Direct bash or `git sync-branch` alias | `bash git-sync-branch.sh` |

## File structure

```
git-branch-sync/
├── SKILL.md                   ← This file — skill specification
├── CLAUDE.md                  ← Project instructions for AI tools
├── git-sync-branch.sh         ← Core bash script
├── .claude/
│   └── settings.json          ← Claude Code config (registers /sync-branch)
├── .cursor/rules/
│   └── git-branch-sync.mdc    ← Cursor rule
└── .trae/rules/
    └── git-branch-sync.md     ← Trae rule
```

## License

MIT.
