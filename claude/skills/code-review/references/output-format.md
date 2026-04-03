# Unified Code Review Output Format

This is the format to produce after synthesizing all 4 subagent results. Group findings by severity, not by agent. Write every comment in the OSS reviewer voice described in SKILL.md — questions over commands, severity prefixes, codebase references, trade-off acknowledgment.

## Template

```markdown
# Code Review

## blocking — Ship-Blockers

### Issue Title — file.ext:LINE [source-agent]

One or two sentences explaining the problem and its blast radius, written the way a senior OSS reviewer would phrase it in a PR comment. Use Socratic framing when the issue involves a subtle assumption ("What happens when X is nil here? I think this panics on the hot path."). Be direct when the issue is clear-cut ("This is a race condition between the read on L42 and the write on L58.").

**Before:**
```lang
current code
```

**After:**
```lang
fixed code
```

---

## suggestion — Worth Fixing

### Issue Title — file.ext:LINE [source-agent]

Frame as a question or observation with rationale: "Have you considered X? The pattern elsewhere in this module is Y — see `sibling_file.ext`." or "I see why you went with X here. One concern is Y — would Z address that?"

**Before:**
```lang
current code
```

**After:**
```lang
fixed code
```

---

## nit — Polish

- **nit:** description — file.ext:LINE [source-agent]. Keep these terse. "nit: raw type" / "nit: `statsToBeCollected` → `types`?"
- Flag 2-3 instances of a pattern, then: "Same pattern in a few more places — mind doing a sweep?"

---

## Scorecard

| Severity | Count |
|----------|-------|
| blocking | N     |
| suggestion | N   |
| nit      | N     |

## What's Working

Call out genuinely good choices — be specific, not generic. Examples:
- "Good use of context cancellation in the gRPC handler — this is exactly the pattern we use elsewhere."
- "The error types here are well-structured and give the caller enough info to act on."
- "Smart call using `extend_from_slice` here — avoids per-element capacity checks."
NOT: "The code looks clean" or "Good job overall"

## Follow-ups

Non-blocking items worth tracking as separate PRs or issues. Frame as: "This is solid as-is. For a follow-up: ..."
1. ...
2. ...

## Quick Wins

Highest-impact, lowest-effort fixes from above:
1. ...
2. ...
3. ...
```

## Rules

- **Before/After code** is REQUIRED for blocking and suggestion findings
- **Before/After code** is OPTIONAL for nits (often just the terse one-liner is enough)
- **Source agent tags**: `[bug-catcher]`, `[style-enforcer]`, `[systems-auditor]`, `[ux-advocate]`
- If a finding was flagged by multiple agents, list all: `[bug-catcher, systems-auditor]`
- **What's Working** must cite specific code decisions, not generic praise
- **Quick Wins** should be ordered by impact/effort ratio
- **Follow-ups** are things worth doing but not worth blocking the PR over
- Omit empty severity sections entirely (don't show "## blocking" with no findings)
- Omit "What's Working" only if genuinely nothing stands out
- **Open with the big picture.** The first sentence of the review should summarize the overall assessment: "This is solid — one blocking issue around concurrency, a few suggestions, and some nits." or "The approach here needs rethinking — see the blocking items below." Don't make the reader scroll to figure out the verdict.
