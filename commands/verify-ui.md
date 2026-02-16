Visually verify UI changes in the browser using Chrome integration.

**Requires**: Chrome integration active. If not connected, suggest `claude --chrome` or `/chrome` and stop.

---

## Instructions

### Step 1: Check Chrome Connection
Verify Chrome integration is available. If not:
- Tell the user: "Chrome integration is not connected. Run `/chrome` or restart with `claude --chrome` to enable browser verification."
- Stop here — do not proceed without Chrome.

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
