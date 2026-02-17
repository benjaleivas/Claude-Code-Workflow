# Recommended Subagent Patterns

## Custom Agents Available

These transversal agents are always available via `~/.claude/agents/`. They have persistent memory and specialized tool access:

| Agent | Memory | Tools | Use When |
|-------|--------|-------|----------|
| `debugger` | user | Read, Write, Edit, Bash, Grep, Glob | Errors, test failures, unexpected behavior |
| `security-reviewer` | user | Read, Grep, Glob, Bash | Auth changes, input handling, RLS, secrets |
| `test-writer` | project | All | After implementing features, coverage gaps |
| `supabase-specialist` | user | All + /spec | Any Supabase work (auth, DB, edge functions) |
| `code-reviewer` | user | Read, Grep, Glob, Bash | Pre-commit reviews, PR reviews, /qa critic |
| `expo-specialist` | user | All | React Native/Expo mobile development |

These supplement (not replace) the ad-hoc subagent patterns below.

---

When spawning subagents for specialized tasks, use these proven patterns:

## Debugger (5-Phase)
1. **Capture**: full error message, stack trace, environment, reproduction steps
2. **Hypothesis**: form theories — code logic? data issue? state problem? config? dependency? race condition?
3. **Isolation**: binary search debugging, minimal reproduction case
4. **Root Cause**: 5 Whys technique — keep asking "why?" until you hit the actual root cause
5. **Fix**: address root cause (not symptoms), add regression test, verify

## Code Reviewer
Review based on dependency graph position:
- **Root/Core** (auth, database, shared utilities): highest standards — stable, tested, explicit
- **Adapters** (API clients, external integrations): high standards — well-tested, error handling
- **Features** (page components, forms): medium standards — functional, readable
- **Leaf** (one-off utilities): lower standards — can be messy

Check for AI-debuggable code:
- Explicit over implicit (direct data flow, no magic strings)
- Colocated context (related code together)
- Linear control flow (flat conditionals, no deep nesting)
- Full type coverage (no `any`, no untyped returns)
- Clear error messages (not "something went wrong")

## Security Reviewer
OWASP Top 10 checks:
- Injection (SQL, XSS, command injection)
- Broken authentication and session management
- Sensitive data exposure
- Broken access control
- Security misconfiguration

Platform-specific:
- Supabase: RLS policies on every table, service role key never in client, auth tokens validated
- React/React Native: no dangerouslySetInnerHTML with user input, sanitize form data
- APIs: rate limiting, key management, CORS configuration

## Bug Fixer
When user pastes external context (bug report, Slack thread, CI logs, docker logs):
1. Read the full context — don't ask for more info unless truly ambiguous
2. Reproduce locally if possible
3. Find root cause using Debugger pattern
4. Fix it
5. Verify with project's test/verify command

Minimize back-and-forth. Boris's rule: "Just say fix."

## Agent Teams (Experimental)

When to use teams instead of subagents:
- Teammates need to share findings with EACH OTHER (not just report back)
- Multiple competing hypotheses need to challenge each other
- Work spans frontend + backend + tests and needs coordination
- Parallel code review from different angles (security, perf, tests)

When NOT to use teams (use subagents or single session instead):
- Sequential tasks with dependencies
- Same-file edits (merge conflicts)
- Simple focused tasks where only the result matters
- The task would take a single agent under ~15 minutes (teams add coordination overhead that only pays off for larger tasks)

Patterns:
- **Parallel review**: spawn 3 reviewers (security, performance, tests), synthesize findings
- **Competing hypotheses**: spawn investigators for different theories, have them challenge each other
- **Cross-layer feature**: frontend teammate, backend teammate, test teammate — each owns their files
- **Delegate mode**: press Shift+Tab so the lead only coordinates, never implements
- **Plan approval**: require teammates to plan before implementing for risky tasks

## Agent Failure Handling

**Stall detection**: If an agent has not made verification progress after 3 consecutive edit-verify cycles, pause and report to the user with findings so far. Do not continue iterating without user input.

**Turn-limit exhaustion**: When an agent exhausts its maxTurns, it must end with a structured summary: root cause hypothesis (if any), evidence gathered, files investigated, and what remains unexplored. This returns to the main session for user decision.
