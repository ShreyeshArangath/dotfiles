---
name: worktree-manager
description: >
  Set up and manage git worktree-based repository structures. Handles bare clone
  initialization, worktree creation with prefix-organized directories, listing,
  removal, and cleanup. Trigger phrases: "set up worktrees", "create worktree",
  "list worktrees", "remove worktree", "cleanup worktrees", "bare clone setup",
  "worktree repo", "new worktree for", "initialize repo with worktrees".
---

# Worktree Manager

Manages git repositories using a bare-clone + worktree pattern. The top-level directory is a bare git repo, and each branch gets its own worktree directory organized by prefix (e.g., `feat/`, `bug/`, `fix/`, `username/`).

## Target Structure

```
<parent-dir>/<repo-name>/          # bare git repo (contains HEAD, config, objects, etc.)
  main/                            # worktree tracking default branch
  upstream-main/                   # (forks only) worktree tracking upstream default branch
  feat/my-feature/                 # worktree for feat/my-feature branch
  bug/some-fix/                    # worktree for bug/some-fix branch
  sarangat/experiment/             # worktree for sarangat/experiment branch
```

---

## Operation 1: Initial Setup (bare clone + worktrees)

**User provides:** a git repo URL and optionally a parent directory (defaults to current directory).

### Steps

1. **Parse repo name** from URL (strip `.git` suffix if present).

2. **Check target path** — if `<parent-dir>/<repo-name>` already exists, stop and inform the user.

3. **Bare clone:**
   ```bash
   git clone --bare <url> <parent-dir>/<repo-name>
   ```

4. **Configure fetch refspecs.** Bare clones don't set up remote-tracking fetch refspecs by default. Fix this for origin:
   ```bash
   cd <parent-dir>/<repo-name>
   git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
   ```

5. **Detect if this is a fork** using the GitHub CLI (if available):
   ```bash
   gh repo view --json parent --jq '.parent.owner.login + "/" + .parent.name'
   ```
   - If `gh` is not installed or the repo is not on GitHub, ask the user: "Is this a fork? If so, what's the upstream repo URL?"
   - If it's a fork, add the upstream remote:
     ```bash
     git remote add upstream <upstream-url>
     git config remote.upstream.fetch '+refs/heads/*:refs/remotes/upstream/*'
     ```

6. **Fetch all remotes:**
   ```bash
   git fetch --all
   ```

7. **Detect the default branch.** Try in order:
   ```bash
   git remote show origin | sed -n 's/.*HEAD branch: //p'
   ```
   If that fails, check if `main` exists, then fall back to `master`.

8. **Create the main worktree** tracking the default branch:
   ```bash
   git worktree add main <default-branch>
   ```

9. **If fork:** detect upstream's default branch and create an upstream-main worktree:
   ```bash
   upstream_default=$(git remote show upstream | sed -n 's/.*HEAD branch: //p')
   git worktree add upstream-main upstream/${upstream_default}
   ```

10. **Print summary** showing the created structure and next steps.

---

## Operation 2: Create Worktree

**User provides:** a branch name (e.g., `feat/my-feature`). Optionally: whether to base it on an existing branch/commit.

### Steps

1. **Must be run from inside a bare repo.** Detect by checking `git rev-parse --is-bare-repository`. If not in a bare repo, look for a bare repo parent or ask the user for the path.

2. **Check if the branch is already checked out** in another worktree:
   ```bash
   git worktree list --porcelain | grep -A1 "branch refs/heads/<branch>"
   ```
   If so, inform the user and offer to navigate to the existing worktree.

3. **Parse the prefix** from the branch name. Everything before the last `/` becomes the directory prefix. If no `/`, the worktree goes at the top level.
   - `feat/my-feature` → prefix `feat/`, dir `feat/my-feature`
   - `sarangat/experiment` → prefix `sarangat/`, dir `sarangat/experiment`
   - `hotfix` → dir `hotfix`

4. **Create prefix directory** if needed:
   ```bash
   mkdir -p <prefix>
   ```

5. **Create the worktree.** If the branch already exists on a remote, track it. Otherwise create a new branch:
   ```bash
   # If remote branch exists:
   git worktree add <dir> <branch>

   # If new branch (base on current default branch):
   git worktree add -b <branch> <dir> <base-ref>
   ```
   Where `<base-ref>` is what the user specified, or defaults to `origin/<default-branch>` (or `upstream/<default-branch>` for forks).

6. **Confirm** with the path to the new worktree.

---

## Operation 3: List Worktrees

Run from inside the bare repo:

```bash
git worktree list
```

Format the output cleanly, showing:
- Worktree path
- Branch name
- Commit hash (short)
- Whether it has uncommitted changes (check with `git -C <path> status --porcelain` for each)

---

## Operation 4: Remove Worktree

**User provides:** the worktree name/path to remove.

### Steps

1. **Check for dirty state** in the worktree:
   ```bash
   git -C <worktree-path> status --porcelain
   ```
   If there are uncommitted changes, warn the user and ask for confirmation before proceeding.

2. **Remove the worktree:**
   ```bash
   git worktree remove <worktree-path>
   ```
   If the worktree is dirty and the user confirms, use `--force`.

3. **Optionally delete the branch** if it has been merged:
   ```bash
   git branch -d <branch-name>
   ```
   If not merged, ask the user if they want to force-delete with `-D`.

4. **Clean up empty prefix directories:**
   ```bash
   # Remove the prefix dir if it's now empty
   rmdir <prefix-dir> 2>/dev/null
   ```

---

## Operation 5: Cleanup Stale Worktrees

### Steps

1. **Prune broken worktrees** (where the directory was manually deleted):
   ```bash
   git worktree prune
   ```

2. **Find merged branches** that still have worktrees:
   ```bash
   git branch --merged origin/<default-branch>
   ```
   Cross-reference with `git worktree list` to identify removable worktrees.

3. **Present the list** of stale/merged worktrees to the user and ask for confirmation before removing each one.

4. Remove confirmed worktrees using the Operation 4 steps.

---

## Edge Cases

- **Repo already exists at target path:** Stop and inform the user. Do not overwrite.
- **Branch already checked out:** Inform the user which worktree has it and offer to navigate there.
- **Dirty worktree removal:** Always warn and require explicit confirmation.
- **Non-GitHub repos:** Skip `gh` fork detection; ask the user directly.
- **Default branch detection fails:** Try `main`, then `master`, then ask the user.
- **Any `/` in branch name creates prefix dirs:** `sarangat/deep/nested/branch` → `mkdir -p sarangat/deep/nested/`.
- **Bare repo detection:** If the user runs a command from a worktree subdirectory, resolve to the bare repo root via `git rev-parse --git-common-dir`.
