---
name: pr-stack-audit
description: Map live dependencies among a project's PRs, identify independent next work, or diagnose child PR bases after a parent merges. Produces a read-only graph and minimal repair plan; does not merge, rebase, retarget, push, or change branch-deletion settings.
---

# PR stack audit

Given a PR, project, or set of branches, report the current dependency graph and the smallest next step. Use live forge state and Git evidence; notes and matching titles are discovery aids, not proof of a dependency. This is a bounded audit, not a shipping or babysitting loop.

## Collect current evidence

1. Resolve the repository and requested project scope. Read its instructions and linked canonical plan/tickets. Inventory worktrees and branches without changing checkouts; identify active owners and dirty work.
2. Through the connected forge tools, fetch relevant open PRs and the merged parents they cite: number, title, URL, state/draft status, exact base/head refs and SHAs, merge result, and checks. Paginate before claiming complete coverage. Use the forge CLI only where the connector cannot provide the needed Git details.
3. Read relevant diffs, commits, imports/schema contracts and connected callers. Distinguish a Git base relationship from a semantic prerequisite: two PRs can target main yet one requires the other's symbols, schema, configuration or deployment. Shared files or related titles alone do not create a dependency.

For each edge, record `prerequisite -> dependent`, its kind (Git base, code/schema, or deployment), and evidence. Label uncertain edges instead of guessing. Fetch exact refs when local inspection is needed; in a bare repo, a fetch may update only `FETCH_HEAD`, so verify SHAs rather than trusting a stale remote-tracking branch.

## After a parent merges

Check the parent's actual merge method/result, whether the child base changed, and what the child's current diff contains. A squash merge may include the parent's patch without making its old commits ancestors of main. Do not conclude “unmerged” from ancestry alone or recommend automatic branch deletion as proof that child diffs will become correct.

Compare the original parent patch, merged result, and child's unique changes. Inspect conflict resolutions and later parent commits; patch equivalence is evidence, not a substitute for checking behavior. Retargeting changes the comparison base; it does not rewrite child history. State whether the child needs no action, a base update, a history repair, or further investigation.

For a repair plan, identify the exact old parent boundary, current child head, and intended new base. If those cannot be established, do not invent a rebase command. Preserve unique child commits, unrelated work, review status, and concurrent ownership. Do not execute the repair, change repository settings, merge a PR, or post comments as part of this audit.

## Report and stop

- A compact table with PR number, title/link, state, base, prerequisites, and evidence-backed blocker.
- A small directed graph with arrows from prerequisite to dependent. Separate code dependencies from deployment ordering; put large unrelated groups in separate graphs.
- The next independent task or smallest repair, its reason, and unresolved evidence. Include exact old-parent, child-head and proposed-base SHAs for a repair. Readiness requires the relevant checks and review; a green badge or merged parent alone is insufficient.

If canonical planning is required, update the existing project/feature page with the graph and current state, preserve links/history, and verify the saved page. Keep Notion references out of PR descriptions. End after the report; applying a repair or dispatching implementation requires the user's requested action.
