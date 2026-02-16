Generate an upfront specification before coding. Use this for medium-complexity tasks that don't need full plan mode.

## Instructions

### Step 1: Identify the Task
If `$ARGUMENTS` is provided, use it as the task description. Otherwise, infer from the current conversation context or ask.

### Step 2: Generate the Spec

Produce a structured specification covering:

**Data Shapes**
- Input types and expected structures
- Output types and response shapes
- Database row shapes (if applicable)
- Which fields are required vs optional, nullability, constraints

**External Service Behaviors**
- How third-party APIs actually behave (reference docs, paste exact response structures)
- Authentication flows and token shapes
- Rate limits and error responses

**Edge Cases**
- Empty data, null values, missing fields
- Network failures, timeouts, partial success
- Concurrent access, race conditions (if applicable)
- Permission errors, auth edge cases

**Success Criteria**
- What does "done" look like?
- How do we verify it works?
- What should the user see/experience?

### Step 3: Present for Approval

Present the spec concisely and ask: "Does this match your expectations? Anything to add or correct before I start implementing?"

### Step 4: After Approval

Proceed with implementation. Reference the spec continuously. If you discover the spec was incomplete during implementation, update it and flag what changed.
