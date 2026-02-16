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

## Where Specs Live
- In plan mode: specs go in Phase 3 (Blueprint) as a required section
- Outside plan mode: invoke `/spec` for a standalone spec
- Specs are saved as part of the plan artifact on disk

## Key Principle
When something fails after implementation, ask: "Was this in the spec?" If not, the spec was incomplete — fix the spec, then fix the code. Over time, specs get better and iterations get shorter.
