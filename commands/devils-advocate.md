---
description: Challenge the current approach with systematic, good-faith skepticism. Use BEFORE finalizing any non-trivial plan.
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob
---

Challenge the current approach with systematic, good-faith skepticism. This is not nitpicking — it's genuine "here's how this could fail" analysis.

**Important**: You are running in a forked context. Read the most recent plan from the project's `.claude/plans/` directory to understand what you're challenging.

## Structured Thinking (MANDATORY)

You MUST use XML thinking tags to make the evaluation transparent:

```xml
<brainstorm>
Reading the plan for: [Plan Title]

Scanning for potential issues in each category:
- Data Integrity: [observations about writes, transactions, crash recovery]
- Silent Failures: [observations about logging, error handling]
- Race Conditions: [observations about concurrency, shared resources]
- Resource Exhaustion: [observations about limits, memory]
- External Dependencies: [observations about APIs, timeouts, fallbacks]
- Edge Cases: [observations about inputs, boundaries]
- Rollback & Recovery: [observations about undo, checkpoints]
- Testing Gaps: [observations about testability, coverage]
- Integration Points: [observations about formats, contracts]
- Security & Access: [observations about auth, permissions, leaks]
</brainstorm>

<analysis>
Evaluating each issue against "Would this wake me at 2am?" test:

Issue 1: [description]
- Production incident risk: [Yes/No - why]
- Urgent response needed: [Yes/No - why]
- Data corruption risk: [Yes/No - why]
- User-visible impact: [Yes/No - why]
→ Severity: [CRITICAL/MEDIUM/LOW]
→ Include as challenge: [Yes/No - passes good faith test?]

[...repeat for all issues]
</analysis>

<decision>
Challenges to present (filtered):
1. [Title] - [Severity] - [Category]
2. ...

Excluded (failed good faith test):
- [Issue] - Reason: [too theoretical / not actionable]
</decision>
```

After structured thinking, present the formal challenge output.

---

## 10-Category Failure Mode Framework

Systematically evaluate EVERY plan against these 10 categories:

### 1. Data Integrity
- Are writes followed by syncs/commits?
- Could partial updates leave inconsistent state?
- What happens on crash mid-operation?

### 2. Silent Failures
- Are errors logged with enough context?
- Could operations fail without anyone knowing?
- Are there catch-all exception handlers hiding problems?

### 3. Race Conditions
- Could concurrent execution cause conflicts?
- Are shared resources properly protected?
- What about startup/shutdown ordering?

### 4. Resource Exhaustion
- Could this run out of memory/connections?
- Are rate limits respected?
- What about disk space for outputs?

### 5. External Dependencies
- What if APIs are down/slow/changed?
- Are timeouts and retries configured?
- What's the fallback behavior?

### 6. Edge Cases
- Empty inputs, huge inputs, malformed inputs?
- Boundary conditions (first/last, min/max)?
- Unicode, special characters, encoding?

### 7. Rollback & Recovery
- Can this be undone if it goes wrong?
- Is there a checkpoint before destructive operations?
- How do you recover from partial completion?

### 8. Testing Gaps
- Is this testable as designed?
- Are there untestable components?
- Does the plan rely on manual verification?

### 9. Integration Points
- Do data formats match between components?
- Are API contracts clearly defined?
- What about version compatibility?

### 10. Security & Access
- Are permissions checked at every layer?
- Could this leak sensitive data?
- What about authentication edge cases?

---

## Challenge-Response-Iterate Workflow

**Round 1: Challenge**

Spawn a subagent to review the plan/code using the 10-category framework. The subagent returns challenges with severity ratings.

**Round 1: Respond**

Address each challenge:
- **DISMISSED**: Not applicable because [specific reason with evidence]
- **ACCEPTED**: Valid concern, mitigated by [specific change to plan]
- **DEFERRED**: Valid but out of scope, tracked as [future task]

Update the plan to reflect accepted mitigations.

**Round 2: Verify**

Re-run the subagent to check:
- Did the fixes introduce new problems?
- Were the dismissals actually justified?
- Are CRITICAL challenges fully resolved?

Two passes maximum. After round 2, summarize what was found and fixed.

---

## The "Would This Wake Me at 2am?" Test

For each potential failure mode, ask:
- Could this cause a production incident?
- Would someone need to respond urgently?
- Could this corrupt data irreversibly?
- Would users notice and be impacted?

If no to all four: probably LOW severity or not worth challenging.
If yes to any: worth raising, with severity proportionate to impact.

## Severity Definitions

- **CRITICAL**: Data loss, security breach, or production outage. Must address before implementation.
- **MEDIUM**: Bugs, degraded performance, or maintenance burden. Should address or consciously accept.
- **LOW**: Minor issues, code smell, or theoretical edge cases. Can dismiss with brief justification.

## Good Faith Framing

Every challenge MUST be:
1. **Specific** — point to exact part of plan that could fail
2. **Justified** — explain WHY this is a concern (not just that it's possible)
3. **Actionable** — the planner can address it concretely
4. **Proportionate** — severity matches actual risk

**Bad (nitpicking):**
> "What if the API returns a 418 I'm a Teapot response?"

**Good (genuine concern):**
> "The plan doesn't address rate limiting. If the API has a 1000/hour limit, a bulk operation could exceed this in Phase 2, causing failures that current error handling won't recover from gracefully."
