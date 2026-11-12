---
name: worktree-manager
description: >
  Set up and manage git worktree-based repository structures. Handles bare clone
  initialization, worktree creation using the repository layout, listing,
  removal, and cleanup. Trigger phrases: "set up worktrees", "create worktree",
  "list worktrees", "remove worktree", "cleanup worktrees", "bare clone setup",
  "worktree repo", "new worktree for", "initialize repo with worktrees".
---

# Worktree Manager

Preserve the repository's existing layout. Resolve it with `git worktree list` and `git rev-parse --git-common-dir --is-bare-repository`; do not convert or relocate an existing clone. A bare repo containing worktrees and a container with a bare `.git/` are both supported.

For this user's new work, use `<repo>/<feature>` with branch `shrey/<feature>`; branch prefixes do not become directory prefixes. Keep general work in `main`. Follow applicable repo instructions and current Notion context before changes.

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

1. **Resolve the existing repository.** Discover the common Git directory and registered worktrees from the current checkout. Use the existing layout; a linked worktree is a valid starting location.

2. **Check whether the intended branch is already checked out.** Normalize the new branch name first, then parse complete records from `git worktree list --porcelain`. Match the exact `branch refs/heads/<branch>` field and retain its associated `worktree` path. Reuse a matching worktree when it belongs to this task; do not create a duplicate or take over another actor's checkout.

3. **Resolve the name and path.** For a new feature, use branch `shrey/<feature>` and sibling directory `<feature>`. Preserve a supplied existing branch name. Never check a feature branch out in `main`.

4. **Verify the starting ref** and that the destination is unused. Follow the repo's update-main rules; preserve dirty work and stop unsafe updates instead of stashing, resetting, or rebasing it.

5. **Create the worktree.** If the branch already exists on a remote, track it. Otherwise create a new branch:
   ```bash
   # If remote branch exists:
   git worktree add <dir> <branch>

   # If new branch (base on current default branch):
   git worktree add -b <branch> <dir> <base-ref>
   ```
   Where `<base-ref>` is what the user specified, or defaults to `origin/<default-branch>` (or `upstream/<default-branch>` for forks).

6. **Confirm** the path and branch through `git worktree list`. Record the worktree and branch in the existing canonical feature page and hub when required.

---

## Operation 3: List Worktrees

Run from any registered checkout or the common repository:

```bash
git worktree list
```

Format the output cleanly, showing:
- Worktree path
- Branch name
- Commit hash (short)
- Whether it has uncommitted changes (check with `git -C <path> status --porcelain` for each worktree; skip the bare-repository record)

---

## Operation 4: Remove Worktree

**User provides:** the worktree name/path to remove.

### Steps

1. Inspect the exact registered path: tracked edits, staged changes, untracked and ignored files, branch head, and active users/processes. A clean tracked diff does not mean the worktree has no local-only files. Do not remove the current working directory, main, or another actor's active worktree.
2. For “clean up merged work,” verify the PR is actually merged into the intended target. Account for squash/rebase merges and later branch commits; ancestry alone is insufficient. Check that the full branch contribution is retained. An open/closed-unmerged PR, unexplained extra commit, or unknown merge evidence is a hold.
3. An explicit cleanup request authorizes the verified clean, merged, inactive set. A request to list candidates authorizes reporting only. Identify valuable local-only files and unresolved ownership before removal; do not use force to bypass them. Preserve branch refs unless deletion was separately requested.
4. Run ordinary `git worktree remove <registered-path>` on the authorized set and re-list. If Git refuses, investigate the reason; do not automatically escalate to force or recursive deletion. Prune stale administrative entries only after verifying the referenced worktree is gone.
5. When requested, close only the exact owning Herdr tab after verifying it has no other ongoing work, using the Herdr skill and applicable remote-session rules. Do not infer ownership from a matching title or close unrelated panes. Update the canonical feature status and remove its worktree row while preserving the page and links; verify saved notes.

---

## Operation 5: Cleanup Stale Worktrees

1. Inventory paths from `git worktree list --porcelain`; do not construct paths from branch names. Use the intended PR base, not automatically the default branch.
2. Classify each as eligible, active, dirty/local-only, unmerged, or unknown using Operation 4's checks. Present path, branch, PR/merge evidence and reason. A stale age or large build directory is not evidence of safe removal.
3. Report only for an audit/list request. For authorized cleanup, remove the eligible set through Operation 4 and leave the others intact. Do not add or run a cache-cleanup schedule as a side effect.
4. Report removed paths and retained branch refs, held candidates with reasons, and verified note/tab updates. If reporting disk savings, measure before and after rather than summing directory estimates.

---

## Edge Cases

- **Repo already exists at target path:** Stop and inform the user. Do not overwrite.
- **Branch already checked out:** Inform the user which worktree has it and offer to navigate there.
- **Dirty or active worktree removal:** Hold and show the specific local-only work or owner; ordinary cleanup authorization does not cover discarding it.
- **Non-GitHub repos:** Skip `gh` fork detection; ask the user directly.
- **Default branch detection fails:** Try `main`, then `master`, then ask the user.
- **Branch and directory names differ:** `shrey/search-filters` uses the sibling worktree `search-filters`, not `shrey/search-filters`.
- **Git directory versus worktree container:** Resolve `git rev-parse --git-common-dir` relative to the command's working directory. A bare `.git/` directory is not the sibling-worktree container. Determine the container from the existing registered paths and layout; never put a new checkout inside the Git directory. Preserve ordinary clones too.
