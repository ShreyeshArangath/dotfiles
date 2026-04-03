# Synthesis Guide: Deduplication & Prioritization

After collecting results from all 4 subagents, follow these rules to produce the unified review.

## Overall Verdict First

Before listing individual findings, open with a 1-2 sentence summary that tells the author where they stand:
- "This is solid work — one blocking issue around concurrency, a few suggestions, and some nits."
- "The approach here needs rethinking — see the blocking items below."
- "Clean changeset. Went through it carefully and found it well written and straightforward to follow."

This is how the best OSS reviewers operate — they tell you the verdict up front so you know whether to panic or relax before reading the details.

## Deduplication Rules

1. **Same file + same line + related concern**: Merge into one finding.
   - Example: bug-catcher flags a race condition, systems-auditor flags the same concurrency issue -> merge, note both perspectives, use higher severity.
   - Tag the merged finding with both agents: `[bug-catcher, systems-auditor]`

2. **Same file + different lines + same root cause**: Merge into one finding covering the broader issue.
   - Example: style-enforcer flags inconsistent naming on lines 12, 45, and 78 -> one finding about the naming pattern. Flag 2-3 instances, then "same pattern in a few more places — mind doing a sweep?"

3. **Different files + same pattern**: Keep as separate findings but note the pattern.
   - Example: bug-catcher finds missing null checks in 3 different files -> 3 findings, but note "This is a recurring pattern across the changeset."

4. **Genuinely distinct issues on the same line**: Keep separate.
   - Example: bug-catcher flags a logic error on line 50, style-enforcer flags naming on the same line -> two separate findings.

## Severity Definitions

The severity system uses the prefix labels from SKILL.md, which map to merge-readiness:

| Severity | Definition | Merge Impact | Examples |
|----------|------------|-------------|---------|
| **blocking** | Data loss, security breach, crash in production, cascading failure, bug under normal use | Must fix before merge | SQL injection, unhandled null deref on hot path, race condition, auth bypass, off-by-one in business logic, missing retry on critical call |
| **suggestion** | Edge case, suboptimal resilience, style deviation from established convention, meaningful improvement | Author decides — worth discussing but not holding the PR | Unicode edge case, inconsistent naming, missing metrics, better algorithm available, confusing error message |
| **nit** | Polish, trivially fixable, defense-in-depth | Never blocks merge | Slightly verbose code, raw type, trailing whitespace, optional config improvement |

## Severity Override Rules

- If bug-catcher rates something blocking and systems-auditor rates the same issue suggestion -> use blocking
- Always use the HIGHER severity when merging findings
- Never downgrade a security finding below blocking
- When in doubt between suggestion and blocking: if the code would work correctly in production 99% of the time, it's a suggestion. If it would fail under normal conditions, it's blocking.

## Follow-up vs. Blocking

A key skill of elite reviewers is knowing when to merge and follow up vs. when to block:
- **Block** when: correctness bug, security issue, data loss risk, API that can't be changed after release
- **Follow-up** when: refactoring that would be cleaner in a separate PR, performance optimization that isn't urgent, documentation improvements, test coverage for secondary paths
- Frame follow-ups explicitly: "This is solid as-is. For a follow-up: consider extracting the retry logic into a shared helper."

## Ordering

Within each severity level, order findings by:
1. Security issues first
2. Correctness issues second
3. Distributed systems issues third
4. Style issues fourth
5. UX issues fifth

## Handling Empty Agent Results

- If an agent returns "No [X] found/concerns/issues", omit that agent's category entirely from the output
- Do NOT include a section saying "The systems-auditor found no issues"
- If ALL agents return empty, the review should say: "Clean changeset. Went through this carefully — no issues found across correctness, style, systems, and UX review."

## Agent Attribution

Every finding MUST include a source agent tag in brackets. This provides transparency about which lens surfaced the issue:
- `[bug-catcher]` — correctness/security finding
- `[style-enforcer]` — convention alignment finding
- `[systems-auditor]` — distributed systems/ops finding
- `[ux-advocate]` — UX/DX finding
- `[bug-catcher, systems-auditor]` — merged cross-agent finding
