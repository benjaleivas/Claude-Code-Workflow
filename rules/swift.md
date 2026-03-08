---
paths:
  - "**/*.swift"
  - "**/Package.swift"
  - "**/*.xcodeproj/**"
---

# Swift — Personal Corrections

These are patterns I've been bitten by. Not generic best practices — specific gotchas that recur in my projects.

## SwiftUI

- **`@State` is view-local** — it resets when the view is recreated. For persistent state, use `@StateObject` (owned) or `@ObservedObject` (injected).
- **`@StateObject` init only once** — `@ObservedObject` can be re-initialized on view re-creation. Use `@StateObject` for objects the view owns.
- **`List` vs `LazyVStack` in `ScrollView`** — `List` has built-in swipe actions and separators but limited customization. `LazyVStack` in `ScrollView` is more flexible but you build everything yourself.
- **`.task` vs `.onAppear`** — `.task` supports `async` and auto-cancels when the view disappears. Always prefer `.task` for async work.
- **View identity matters** — SwiftUI uses structural identity to decide if a view is "the same." Conditional views (`if/else`) create new identity = animation breaks. Use `.opacity(0)` or `AnyView` to preserve identity.

## Concurrency

- **`@MainActor` for UI updates** — any code that touches UI state must be on the main actor. `@Published` properties in an `@Observable` class should be updated on `@MainActor`.
- **`Task` captures `self`** — if `self` is a class, the Task retains it. Use `[weak self]` in `Task { }` when the task might outlive the object.
- **Actor isolation is viral** — once a property is actor-isolated, accessing it from outside requires `await`. Plan actor boundaries upfront.
- **`AsyncSequence` for streams** — use `AsyncStream` to bridge callback-based APIs to structured concurrency. Don't mix Combine and async/await in the same data flow.

## Common Pitfalls

- **Optional chaining silences bugs** — `user?.name?.count` returns `nil` instead of crashing on `nil` user. Sometimes crashing early is better (use `!` with a comment or `guard let`).
- **`Codable` requires all properties** — if the JSON is missing a field that's non-optional, decoding fails silently. Use `CodingKeys` and `decodeIfPresent` explicitly.
- **`struct` vs `class`** — default to `struct`. Only use `class` for identity semantics, inheritance, or Objective-C interop.
- **`guard let` over `if let`** — `guard` exits early, reducing nesting. Use `if let` only for optional binding in short scopes.
- **`String` is not `[Character]`** — string indices are not integers. Use `string.index(string.startIndex, offsetBy: n)` or higher-level APIs.
- **`@Environment` values are injection points** — they must be set by an ancestor view. Missing values silently use defaults, which may not be what you expect.
