---
paths:
  - "**/*.py"
  - "**/Pipfile"
  - "**/pyproject.toml"
---

# Python — Personal Corrections

These are patterns I've been bitten by. Not generic best practices — specific gotchas that recur in my projects.

## Type Hints

- **Use `from __future__ import annotations`** — enables postponed evaluation, avoids forward reference issues, required for `X | Y` union syntax in Python <3.10.
- **Prefer `dataclass` over plain dicts** — dicts are untyped bags. Dataclasses give you autocomplete, validation, and clear shape.
- **Use `Protocol` for structural typing** — don't force inheritance. If it quacks like a duck, type it as a Protocol.

## Async

- **`asyncio.gather` swallows exceptions by default** — use `return_exceptions=True` to see all errors, not just the first one.
- **Don't mix sync and async I/O** — calling `requests.get()` inside an async function blocks the event loop. Use `httpx` or `aiohttp`.
- **`async with` for connections** — always use context managers for DB connections, HTTP clients, and file handles in async code.

## Data Processing

- **Mutable default arguments** — `def f(items=[])` is a classic bug. The list is shared across calls. Use `None` and create inside.
- **Dictionary `.get()` vs bracket access** — `.get()` returns `None` silently on missing keys. Use bracket access when the key must exist (fail loud).
- **`datetime.now()` is naive** — always use `datetime.now(timezone.utc)` or `datetime.now(tz=ZoneInfo("..."))`. Naive datetimes cause subtle timezone bugs.

## Testing (pytest)

- **Fixtures over setup methods** — pytest fixtures are composable and explicit. `setUp`/`tearDown` from unittest are implicit and don't compose.
- **`parametrize` for input variations** — don't write 5 test functions that differ only in input. Use `@pytest.mark.parametrize`.
- **Mock at the boundary, not internally** — mock the HTTP client, not the function that calls it. Internal mocks make tests brittle.

## Common Pitfalls

- **`is` vs `==`** — `is` checks identity, `==` checks value. Only use `is` for `None`, `True`, `False`.
- **String concatenation in loops** — use `"".join(parts)` instead. String `+=` is O(n^2).
- **`except Exception` hides bugs** — catch specific exceptions. Bare `except:` catches `KeyboardInterrupt` and `SystemExit`.
- **`os.path` vs `pathlib`** — use `pathlib.Path` for all path operations. It's cleaner and cross-platform.
- **Virtual environments** — always use one. Global pip installs break other projects. Prefer `uv` for speed.
