# Spec Before Code

Before implementing any non-trivial task, outline the specification FIRST. This catches misunderstandings upfront and dramatically reduces iteration cycles.

## When to Spec
- Tasks involving external services (Stripe, Supabase, third-party APIs)
- Data processing pipelines or transformations
- Complex state management (navigation flows, auth states, form wizards)
- Database schema changes or migrations
- Any task where the expected output shape is ambiguous

## What the Spec Must Include
1. **Data shapes**: Expected input/output types, API response structures, DB row shapes
2. **Contracts**: Which fields are required vs optional, nullability, constraints
3. **External behaviors**: How third-party services actually behave (not how you assume they do). Reference docs or paste exact response structures when possible.
4. **Edge cases**: What happens on empty data, network failure, partial success, rate limits?
5. **Success criteria**: How do we know this works? What does "done" look like?
6. **Error & Rescue Map** (backend/API work): For every operation that can fail, document the failure path explicitly. Zero silent failures — every error must be visible to the system, the developer, or the user.

### Error & Rescue Map Template

For each function/endpoint that touches external services, databases, or user input:

| Operation | Failure Mode | Error Type | Handling | User-Visible Impact |
|-----------|-------------|------------|----------|-------------------|
| `fetchBill()` | Congress.gov rate limit | `RateLimitError` | Retry with backoff (3 attempts) | "Loading..." → toast after 10s |
| `fetchBill()` | Network timeout | `TimeoutError` | Return cached if available, else error | "Unable to reach Congress.gov" |
| `saveDraft()` | Supabase RLS denied | `PostgrestError` (403) | Log + redirect to login | "Session expired, please sign in" |
| ... | ... | ... | ... | ... |

**When to include**: Any spec involving API calls, database writes, auth flows, or external service integration. Skip for pure UI/styling work.

**Key principle**: If a row has "Handling: none" or "User-Visible Impact: silent", that's a gap. Every failure must either be handled or explicitly acknowledged as accepted risk.

## Where Specs Live
- In plan mode: specs go in Phase 3 (Blueprint) as a required section
- Outside plan mode: invoke `/spec` for a standalone spec
- Specs are saved as part of the plan artifact on disk

## Research Phase (Before Choosing Tools)

Before committing to a library, service, or architectural approach, search the ecosystem:

### Search Order
1. **MCP servers first**: Check configured servers (`search_mcp_registry`) — if an integration already exists, use it instead of building a wrapper
2. **Package registries**: npm (TypeScript), PyPI (Python), Swift Package Index (Swift) — search for existing solutions
3. **GitHub**: Look for well-maintained implementations of the pattern you need

### Quick Evaluation (3-5 options max)
For each candidate, check:
- Last commit date (active maintenance?)
- Open issues count and responsiveness
- License compatibility (MIT/Apache preferred)
- Dependency footprint (fewer = better)
- Weekly downloads / stars (adoption signal)

### Four Outcomes
| Outcome | When | Action |
|---------|------|--------|
| **Adopt** | Existing solution fits well | Install, link to docs, use as-is |
| **Extend** | Almost fits, needs a thin wrapper | Write adapter/wrapper, document the gap |
| **Compose** | No single solution, but parts exist | Integrate multiple sources, document the glue |
| **Build** | Nothing suitable or too risky to depend on | Roll custom, document why existing options were rejected |

### When to Research
- Adding a new dependency or service integration
- Choosing between architectural approaches (e.g., state management, auth strategy)
- Any task where you'd otherwise guess at the "right" library

### When to Skip
- The project already has an established pattern for this type of work
- The user specified exactly what to use
- The task is purely internal logic with no external dependencies

## Key Principle
When something fails after implementation, ask: "Was this in the spec?" If not, the spec was incomplete — fix the spec, then fix the code. Over time, specs get better and iterations get shorter.
