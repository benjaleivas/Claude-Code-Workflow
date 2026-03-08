---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.mts"
---

# TypeScript — Personal Corrections

These are patterns I've been bitten by. Not generic best practices — specific gotchas that recur in my projects.

## Type System

- **Never use `enum`** — use `as const` objects or string literal unions. Enums have weird runtime behavior and don't tree-shake.
- **Prefer `type` over `interface`** — interfaces merge implicitly, types don't. Merging is almost never what I want.
- **Avoid `any`** — use `unknown` and narrow. If you must escape the type system, use `as` with a comment explaining why.
- **Generic constraints over overloads** — overloads are harder to maintain and often hide the actual contract.

## Async / Promises

- **Always handle promise rejections** — unhandled rejections crash Node processes. Every `.then()` needs a `.catch()`, or use `try/catch` with `await`.
- **Don't mix `await` and `.then()`** — pick one style per function. Mixing creates subtle ordering bugs.
- **`Promise.all` fails fast** — if you need all results even when some fail, use `Promise.allSettled`.

## React / React Native Patterns

- **`useEffect` cleanup** — always return a cleanup function for subscriptions, intervals, and event listeners. Missing cleanup = memory leaks in RN.
- **`FlatList.onEndReached` fires on mount** — if the initial data is shorter than the viewport. Guard with a `hasScrolled` flag.
- **Don't put objects as `useEffect` deps** — they create a new reference every render. Extract the primitive value or use `useMemo`.
- **`useState` setter is async** — don't read state immediately after setting it. Use `useEffect` to react to state changes.

## Imports / Modules

- **Barrel exports (`index.ts`) slow down bundlers** — especially in large projects. Import directly from the source file when possible.
- **Side-effect imports are invisible** — `import './setup'` runs code but you can't tell what. Document why it exists.

## Common Pitfalls

- **`Array.sort()` mutates in place** — if you need immutability, spread first: `[...arr].sort()`.
- **`JSON.parse` can throw** — always wrap in try/catch. Never trust external data to be valid JSON.
- **`typeof null === 'object'`** — the classic JS gotcha. Always check `!== null` before typeof checks.
- **Template literal types are powerful but unreadable** — use them for simple patterns, create helper types for complex ones.
- **Zod schemas are the source of truth** — derive TypeScript types from schemas (`z.infer<typeof schema>`), not the other way around.
