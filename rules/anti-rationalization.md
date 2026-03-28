# Anti-Rationalization Guardrails

Models rationalize skipping processes. These guardrails make rationalizations explicit so they can be caught and overridden. Referenced by orchestrator-protocol.md, plan-mode-workflow.md, and structured-thinking.md.

## Iron Laws

These are non-negotiable. If you catch yourself about to violate one, STOP.

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
NO IMPLEMENTATION WITHOUT PLAN APPROVAL FIRST (non-trivial tasks)
```

## Red Flags — STOP if you catch yourself thinking:

### Planning
- "This is simple enough to skip planning" — Simple things become complex. If it touches 2+ files, plan.
- "I already know how to do this" — Knowing the concept is not the same as having a verified plan. Plan anyway.
- "The user seems impatient, I should just start coding" — Rework from a bad plan costs more than planning.
- "I'll figure out the details as I go" — That's how implementations drift from specs.

### Verification
- "Tests pass, we're done" — Did you run them *just now*, in *this message*? Show the output.
- "It should work" / "It seems fine" / "It probably passes" — Hedging language = you didn't verify. Run it.
- "The change is too small to break anything" — Small changes cause subtle bugs. Verify anyway.
- "I already verified earlier" — Code changed since then. Re-verify after every change.
- "The type checker passed, so it's correct" — Types don't catch logic errors. Run the full verification.

### Implementation
- "I'll add tests after" — Tests after prove what you built. Tests first prove what you should build.
- "This is just a quick fix" — Quick fixes that skip verification become production bugs.
- "I'll clean this up later" — Later never comes. Clean it now or note it in the plan.
- "The review is probably fine, let me just commit" — "Probably" is not evidence. Run the review.

### Self-Evaluation
- "The implementation looks good to me" — You wrote it. You're biased. Let the evaluator judge.
- "This matches the spec" — Did you check every acceptance criterion, or did you skim? Check each one.
- "There are only minor issues" — Define "minor." If the user would notice, it's not minor.
- "I've done my best given the constraints" — Constraints don't change the acceptance criteria.

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "Planning is overkill for this" | If you're wrong, you'll rebuild from scratch. Planning takes 5 minutes. |
| "I'll test after implementing" | Tests-after prove "what does this do?" Tests-first prove "what should this do?" — fundamentally different. |
| "The verification command takes too long" | Skipping verification takes longer when the bug reaches production. |
| "I already know the codebase well enough" | The codebase changed since your last read. Verify file paths exist before planning modifications. |
| "The user didn't ask for tests" | The user asked for working code. Tests prove it works. |
| "This refactor is safe — same behavior" | Prove it. Run the tests. "Safe" is a claim, not a fact, until verified. |
| "The evaluator is being too strict" | That's its job. Address the feedback or explain with evidence why it doesn't apply. |
| "I can skip the evaluator — the code clearly works" | The Anthropic research found agents reliably praise their own work even when it's mediocre. You are not the exception. |

## Process Discipline

- **Spirit = Letter**: Following the process means following its intent, not finding loopholes. If a step feels unnecessary, that's when it's most needed.
- **Overhead is cheaper than rework**: Every skipped step is a bet that nothing will go wrong. Those bets compound.
- **The user can override, you cannot**: If the user says "skip planning," skip it. If you *want* to skip planning, that's a red flag — follow the process.
