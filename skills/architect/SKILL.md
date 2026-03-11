---
description: "Design system architecture and produce Architecture Decision Records (ADRs). Use when the user asks to design, architect, or structure a system — e.g. 'how should I structure...', 'design the architecture for...', 'what's the right approach for...', 'system design for...'."
---

# /architect — System Architecture & ADR Generator

You have been invoked as the architect skill. Your job is to produce a clear architectural recommendation via an Architecture Decision Record (ADR).

## How This Works

Spawn a **read-only architect subagent** to do the actual analysis. This keeps the main conversation context clean while giving the architect full codebase access.

### Step 1: Gather Context

Before spawning the agent, collect from the user:
- What capability is being added or changed?
- What are the constraints (performance, compatibility, timeline)?
- Any strong preferences or non-negotiables?

Use AskUserQuestion if the request is ambiguous. If the user's message already provides enough context, skip straight to Step 2.

### Step 2: Spawn Architect Agent

Use the Agent tool with these parameters:
- `subagent_type`: `"Plan"`
- `model`: `"opus"` (architecture decisions need deep reasoning)
- `mode`: `"plan"` (read-only — no edits)

Include in the agent prompt:
1. The user's request and any gathered context
2. The full architect process (from `~/.claude/agents/architect.md`)
3. Reference to the ADR template (from `./adr-template.md` in this skill directory)
4. Instruction to produce the ADR, file list, and risk assessment

### Step 3: Present Results

When the agent returns:
1. Present the ADR to the user
2. Highlight the recommended approach and its key trade-off
3. List the files that would need to change
4. Note the biggest risk and its mitigation

### Step 4: Next Steps

After presenting, offer via AskUserQuestion:
- **Enter plan mode** (recommended) — use the ADR as input for a full implementation plan
- **Save ADR only** — write to `{project}/.claude/plans/ADR-YYYY-MM-DD_description.md` for later
- **Iterate** — challenge assumptions or explore a different approach

## When to Use This Skill

- Plan mode Phase 1 identifies the task as architecture-heavy
- User asks "how should I structure this?" or "what's the right approach?"
- The orchestrator's Phase 2.5 (competing architectures) needs architectural analysis
- Major refactors or technology selection decisions
- New system design where multiple viable approaches exist

## Relationship to the Agent File

The `~/.claude/agents/architect.md` file contains the full architect protocol. This skill is the **user-facing invocation path** — it handles context gathering and result presentation. The agent file is the **orchestrator-facing path** — it's used when the orchestrator spawns the architect directly in agent sequences.

Both paths use the same underlying process. No duplication.
