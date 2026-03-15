---
description: Visually verify UI changes in the browser. Use after frontend or UI changes to check layout, console errors, and visual regressions via preview server or Chrome.
---

Visually verify UI changes in the browser.

**Priority order**:
1. **gstack browse daemon** (fastest, lowest context cost) — if `~/.claude/skills/gstack/browse/dist/browse` exists
2. **Claude Preview** — if `.claude/launch.json` exists and `preview_*` tools are available
3. **Chrome MCP** — fallback if neither above is available

---

## Instructions

### Step 0a: Check for gstack Browse Daemon
If `~/.claude/skills/gstack/browse/dist/browse` exists:
1. Set browse binary with Bun in PATH: `export PATH="$HOME/.bun/bin:$PATH" && B=~/.claude/skills/gstack/browse/dist/browse`
2. Navigate: `$B goto <url>` (daemon auto-starts on first call, ~3s; subsequent calls ~100-200ms)
3. Snapshot: `$B snapshot -i` — shows page structure with interactive element refs (`@e1`, `@e2`, etc.)
4. Screenshot: `$B screenshot <output-path>` — captures full page
5. Console errors: `$B console --level error`
6. Network failures: `$B network --failed`
7. Skip to Step 5 (Report)

Note: Browse daemon persists between calls (30-min idle timeout). Cookies, tabs, and localStorage carry over. For authenticated testing, use `$B cookie-import-browser <domain>` to import cookies from a real browser.

### Step 0b: Check for Preview Server
If `.claude/launch.json` exists and `preview_*` MCP tools are available:
1. Start the preview server with `preview_start` (if not already running)
2. Use `preview_screenshot` for visual check
3. Use `preview_snapshot` for content/structure verification
4. Use `preview_console_logs` for error checking
5. Use `preview_network` with `filter: "failed"` for network failures
6. Skip to Step 5 (Report) — Chrome is not needed

### Step 1: Check Chrome Connection (fallback)
If neither browse daemon nor preview server is available, verify Chrome integration. If not connected:
- Tell the user: "No browse daemon, preview server, or Chrome connection available. Install gstack browse (`~/.claude/skills/gstack/`), add `.claude/launch.json`, or run `claude --chrome`."
- Stop here.

### Step 2: Determine URL
If `$ARGUMENTS` contains a URL or path, use it. Otherwise:
- Check for a running dev server by looking at common ports:
  - `localhost:3000` (Next.js, CRA, Vite)
  - `localhost:5173` (Vite default)
  - `localhost:8080` (generic)
  - `localhost:8081` (Metro bundler)
  - `localhost:19006` (Expo web)
- Check `package.json` scripts for port hints (`"dev"`, `"start"`, `"web"`)
- If can't determine, ask the user for the URL

### Step 3: Navigate and Screenshot
1. Open a new Chrome tab
2. Navigate to the URL
3. Wait for the page to load (watch for network idle)
4. Take a screenshot and show it to the user

### Step 4: Check for Issues
1. **Console errors**: Read browser console, filter for `error|warning|exception|failed`
2. **Network failures**: Check for any 4xx/5xx HTTP responses
3. **Visual check**: Describe what you see on the page — layout, content, any obvious issues

### Step 5: Report
Present findings:
- **Visual**: describe the page and screenshot
- **Console**: list any errors or warnings (or "Clean — no errors")
- **Network**: list any failed requests (or "All requests succeeded")
- **Verdict**: PASS (no issues) or ISSUES FOUND (with details and suggested fixes)

---

## Optional Flags (via $ARGUMENTS)

- **URL**: `/verify-ui localhost:3000/dashboard` — go directly to this URL
- **`--record`**: Start a GIF recording before navigation, stop after checks. Save the GIF for sharing.
- **`--full`**: Also check responsive breakpoints:
  1. Desktop (1280px wide) — screenshot
  2. Tablet (768px wide) — screenshot
  3. Mobile (375px wide) — screenshot
  Report any layout issues at each breakpoint.
