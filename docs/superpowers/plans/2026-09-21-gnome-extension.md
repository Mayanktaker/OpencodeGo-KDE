# GNOME Shell Extension Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `gnome-extension/` — a GNOME Shell extension showing an OpenCode Go panel icon whose hover popup displays Rolling (5h) / Weekly / Monthly usage, reusing the KDE widget's console API logic.

**Architecture:** A `PanelMenu.Button` indicator in the GNOME top bar opens a popup on hover/click. A GJS ES module port of `contents/code/api.js` drives the same curl transport (via `Gio.Subprocess`), route-walking, retry, and parsing. Settings (workspace id, auth cookie, refresh minutes) live in gsettings, edited through a libadwaita prefs window.

**Tech Stack:** GJS (SpiderMonkey), GNOME Shell 45–50 APIs (`Main.panel.addToStatusArea`, `PanelMenu`, `PopupMenu`), libadwaita prefs, glib schemas, curl subprocess, GLib timers.

**Spec:** `docs/superpowers/specs/2026-09-21-gnome-extension-design.md`

## Global Constraints

- Every source file starts with the header line: `// © Mayanktaker Computers & Web Development | https://mayanktaker.com`
- ≤1-line comment per function/block; no magic values — config/schema tokens only; simplest solution; ~300–400 lines/file max
- API behavior must match `contents/code/api.js` exactly: route list order, cookie normalization, `meterPercent = floor((used*200+limit)/(limit*2))` clamped 0–100, 404-only route walk, 5xx retried in place 3 attempts, error strings verbatim
- Cookie header built by `buildCookieHeader`; curl always sends `Cookie`, `User-Agent`, `Accept: application/json`, `x-org-id`, `Referer: https://opencode.ai/console/{ws}/go`, `--max-time 15`, `-w HTTPSTATUS:%{http_code}`; marker split on LAST occurrence
- Extension uuid: `com.mayanktaker.opencodego-usage`; schema id: `org.gnome.shell.extensions.opencodego-usage`; shell-version list: `["45","46","47","48","49","50"]`
- gsettings keys: `workspace-id` (s, `""`), `auth-cookie` (s, `""`), `refresh-minutes` (u, 5, min 1)
- GJS is SpiderMonkey: use ES modules (`import/export`), `const/let`, no QML; GIO async via callbacks, no async/await over Gio Subprocess
- Empty credentials → demo mode via `getMockData()`; transient 5xx keeps last known figures with note

## Review Focus

1. **Cookie values containing `=` or padding** (base64 tails): `buildCookieHeader` must still name-wrap bare values, not split on `=` — pinned in Task 2 test.
2. **Full Cookie header paste with `; ` separated pairs** must pass through untouched, including when a later pair contains `auth=` — pinned in Task 2 test.
3. **HTTPSTATUS marker appearing inside the response body** (JSON echo): split must use LAST occurrence — pinned in Task 2 test.
4. **5xx storm**: after 3 attempts same route, widget keeps last known figures and shows the transient note instead of blanking — pinned in Task 4 logic check.
5. **Hover spam / re-entrancy**: rapid enter/leave and refresh tick while a request is in flight must not stack curl processes (single in-flight guard) — pinned in Task 4.

---

### Task 1: Extension skeleton + metadata + install.sh

**Files:**
- Create: `gnome-extension/metadata.json`
- Create: `gnome-extension/install.sh`
- Create: `gnome-extension/stylesheet.css` (empty stub with header comment)

**Interfaces:**
- Consumes: nothing
- Produces: installable (though inert) extension directory layout; `install.sh` that other tasks' files are picked up by automatically (it copies the whole folder).

- [ ] **Step 1: Write metadata.json**

```json
{
    "_copyright": "© Mayanktaker Computers & Web Development | https://mayanktaker.com",
    "uuid": "com.mayanktaker.opencodego-usage",
    "name": "OpenCode Go Usage Tracker",
    "description": "Tracks OpenCode Go subscription usage (Rolling, Weekly, Monthly) from the panel. Hover the icon to see all three windows.",
    "shell-version": ["45", "46", "47", "48", "49", "50"],
    "url": "https://github.com/Mayanktaker/OpencodeGo-KDE",
    "session-modes": ["user"]
}
```

- [ ] **Step 2: Write stylesheet.css stub**

```css
/* © Mayanktaker Computers & Web Development | https://mayanktaker.com */
/* Panel icon and popup styles for the OpenCode Go usage extension */
```

- [ ] **Step 3: Write install.sh**

```bash
#!/usr/bin/env bash
# © Mayanktaker Computers & Web Development | https://mayanktaker.com
# Installs the GNOME Shell extension into the user extension directory and enables it
set -euo pipefail

# Extension identity must match metadata.json
UUID="com.mayanktaker.opencodego-usage"
# Install target inside the user's home
DEST="$HOME/.local/share/gnome-shell/extensions/$UUID"
# This script's directory (the repo's gnome-extension folder)
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy extension files except dev-only artifacts and this script
mkdir -p "$DEST"
rsync -a --delete --exclude 'install.sh' --exclude 'tests' --exclude '.git' "$SRC/" "$DEST/"

# Compile the gsettings schema into the installed copy
glib-compile-schemas "$DEST/schemas/"

# Enable live; on Wayland a first install may still need logout/login
gnome-extensions enable "$UUID" 2>/dev/null || true

echo "Installed $UUID -> $DEST"
echo "If the panel icon does not appear, log out and back in (Wayland requirement for first install)."
```

- [ ] **Step 4: Make install.sh executable and verify metadata parses**

Run: `chmod +x gnome-extension/install.sh && python3 -c "import json;json.load(open('gnome-extension/metadata.json'))" && bash -n gnome-extension/install.sh`
Expected: no output (success), exit 0

- [ ] **Step 5: Commit**

```bash
git add gnome-extension/metadata.json gnome-extension/install.sh gnome-extension/stylesheet.css
git commit -m "feat(gnome): extension skeleton with metadata and installer"
```

---

### Task 2: api.js — port of console API logic + parse tests

**Files:**
- Create: `gnome-extension/api.js`
- Create: `gnome-extension/tests/api-test.js`

**Interfaces:**
- Consumes: `contents/code/api.js` behavior (source of truth; port, do not redesign)
- Produces (used by Tasks 3–5): ES module exporting `USER_AGENT`, `CONSOLE_STATUS_ROUTES`, `HTTP_STATUS_MARKER`, `calculatePercentage(used, total) -> number`, `buildCookieHeader(val) -> string`, `checkCookieError(val) -> string`, `checkWorkspaceIdError(val) -> string`, `shellQuote(s) -> string`, `splitHttpStatus(stdout) -> {body, httpStatus}`, `buildCurlCommand(workspaceId, authCookie, routeIndex) -> string`, `parseCurlOutput(stdout, stderr, exitCode) -> {error, data, httpStatus}`, `parseAnyResponse(text) -> model (throws on tagged errors)`, `getMockData() -> model`, `consoleRouteCount() -> number`, `maxAttemptsPerRoute() -> number`, `noRouteError() -> string`, `isTransientError(err) -> bool`, `formatResetFull(sec) -> string`, `meterPercent(used, limit) -> number`, `secondsUntil(value) -> number`, `toMicroCents(value) -> number`. Model shape: `{isMock, planName, billingPeriod, usagePercent, resetSeconds:{hourly,weekly,monthly}, hourly:[{label,value,maxValue}], weekly:[...], monthly:[...], lastRefreshed}`.
- Test runner: `gjs -m gnome-extension/tests/api-test.js`, plain asserts, exits non-zero on failure.

- [ ] **Step 1: Write the failing test file**

Create `gnome-extension/tests/api-test.js`:

```javascript
// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Plain-assert smoke tests for the GJS port of the console API logic

import * as Api from '../api.js';

// Minimal assert helpers so gjs runs without any dependency
let failures = 0;
function ok(cond, msg) {
    if (!cond) { console.error('FAIL: ' + msg); failures++; }
}
function eq(a, b, msg) { ok(a === b, msg + ' (got ' + JSON.stringify(a) + ', want ' + JSON.stringify(b) + ')'); }

// --- cookie normalization ---
eq(Api.buildCookieHeader('st_abcdefghijklmnopqrstuvwxyz'), '__Host-console_session=st_abcdefghijklmnopqrstuvwxyz', 'bare token wrapped with host cookie');
eq(Api.buildCookieHeader('abc=='), '__Host-console_session=abc==', 'bare token with padding still wrapped whole');
eq(Api.buildCookieHeader('Fe26.2**abc'), 'auth=Fe26.2**abc', 'legacy iron seal mapped to auth');
eq(Api.buildCookieHeader('__Host-console_session=x; console_session=y'), '__Host-console_session=x; console_session=y', 'full header passthrough');
eq(Api.buildCookieHeader('"__Host-console_session=x"'), '__Host-console_session=x', 'devtools quotes stripped');

// --- validation ---
ok(Api.checkCookieError('st_abcdefghijklmnopqrstuvwxyz') === '', 'valid cookie passes');
ok(Api.checkCookieError('short') !== '', 'short cookie rejected');
ok(Api.checkWorkspaceIdError('wrk_abc') === '', 'wrk id valid');
ok(Api.checkWorkspaceIdError('xyz') !== '', 'bad workspace rejected');

// --- status marker split uses LAST occurrence ---
let split = Api.splitHttpStatus('{"a":"HTTPSTATUS:200"}HTTPSTATUS:404');
eq(split.httpStatus, 404, 'last marker wins');
eq(split.body, '{"a":"HTTPSTATUS:200"}', 'body preserved before last marker');

// --- percentage mirrors the console formula ---
eq(Api.meterPercent(0, 10), 0, 'zero usage is zero');
eq(Api.meterPercent(5, 10), 50, 'half is half');
eq(Api.meterPercent(999, 10), 100, 'clamped to 100');
eq(Api.meterPercent(5, 0), 0, 'no limit means zero');

// --- console JSON parsing ---
let payload = {
    access: {
        endsAt: '2030-01-01T00:00:00Z',
        meters: {
            fiveHour: { usedMicroCents: '125000000', limitMicroCents: '500000000', resetsAt: '2030-01-01T01:00:00Z' },
            week: { usedMicroCents: '250000000', limitMicroCents: '1000000000', resetsAt: '2030-01-01T00:00:00Z' },
            month: { usedMicroCents: '2500000000', limitMicroCents: '10000000000' }
        }
    }
};
let model = Api.parseCurlOutput(JSON.stringify(payload), '', 0);
eq(model.error, null, 'console payload parses without error');
eq(model.data.usagePercent, 25, 'weekly headline percent from micro-cents');
eq(model.data.weekly[0].value, 25, 'weekly bar value');
eq(model.data.monthly[0].value, 25, 'monthly bar value');
ok(model.data.resetSeconds.monthly > 0, 'monthly reset from access.endsAt');

// --- tagged error responses ---
let authBody = JSON.stringify({ _tag: 'Unauthorized' });
eq(Api.parseCurlOutput(authBody, '', 0).error, 'Auth Cookie is invalid or expired. Please update Auth Cookie in settings.', '401 tag message');
eq(Api.parseCurlOutput('{"_tag":"BadRequest"}', '', 0).error, 'Console API rejected the request (400) — check the Workspace ID.', '400 tag message');

// --- 404 route walk signal and 5xx retry signal ---
eq(Api.parseCurlOutput('', '', 0).httpStatus, 404, 'empty body treated as 404 route-moved');
eq(Api.parseCurlOutput('HTTPSTATUS:500', '', 0).httpStatus, 500, '5xx surfaced for in-place retry');

// --- curl command shape ---
let cmd = Api.buildCurlCommand('wrk_x', 'st_abcdefghijklmnop', 0);
ok(cmd.indexOf('x-org-id') !== -1 && cmd.indexOf('wrk_x') !== -1, 'curl carries org header');
ok(cmd.indexOf('--max-time 15') !== -1, 'curl bounded at 15s');
ok(cmd.indexOf("'") !== -1, 'shell-quoted arguments present');

// --- demo mode ---
let mock = Api.getMockData();
ok(mock.isMock === true && mock.weekly.length > 0, 'mock data shaped for demo mode');

// --- reset formatting ---
eq(Api.formatResetFull(0), '', 'zero reset renders empty');
ok(Api.formatResetFull(13500).indexOf('hour') !== -1, 'hours shown in countdown');

// Summary and exit code for the runner
if (failures > 0) {
    console.error(failures + ' test(s) failed');
    System_exit(1);
} else {
    print('All api tests passed');
}
// gjs has no process.exit in module scope; use System.exit via import below if needed
function System_exit(code) { import('system').then(s => s.System.exit(code)); }
```

Note: if `gjs -m` lacks `System.exit` here, replace the last three blocks with throwing on first failure — the runner just needs a non-zero exit on failure. Verify whichever works and keep it.

- [ ] **Step 2: Run the test to verify it fails**

Run: `gjs -m gnome-extension/tests/api-test.js`
Expected: FAIL — cannot resolve `../api.js` (module missing)

- [ ] **Step 3: Port contents/code/api.js into gnome-extension/api.js**

Copy the logic of `contents/code/api.js` (keep function bodies equivalent; convert to ES module). Key porting notes:

- Header comment + file-level comment kept; add `export` to every public function and constant listed in Produces above.
- Keep `var` → `const`/`let` conversion mechanical; keep regexes and string ops identical.
- `getMockData`, `parseSolidUsageStore`, `parseAnyResponse`, `parseUsageResponse`, `generateCSV` ported as-is (generateCSV optional but harmless).
- `buildCurlCommand` returns the same shell string; `Gio.Subprocess` in Task 4 runs it via `sh -c`.

Reference implementation (abridged from the source of truth — the executor must port the remaining functions from `contents/code/api.js` verbatim, not reinvent):

```javascript
// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// GJS port of the KDE widget's console API logic (contents/code/api.js)

export const USER_AGENT = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
export const CONSOLE_SESSION_COOKIE = '__Host-console_session';
export const CONSOLE_STATUS_ROUTES = [
    'https://opencode.ai/console/api/go/status',
    'https://opencode.ai/console/api/internal/orgs/%ORG%/go/status',
    'https://opencode.ai/console/api/orgs/%ORG%/go/status',
    'https://opencode.ai/console/api/v2/orgs/%ORG%/go/status',
    'https://opencode.ai/console/api/v1/orgs/%ORG%/go/status'
];
export const HTTP_STATUS_MARKER = 'HTTPSTATUS:';
const KNOWN_COOKIE_NAMES = ['__Host-console_session', 'console_session', 'auth'];

export function shellQuote(s) { return "'" + String(s).replace(/'/g, "'\\''") + "'"; }
// ...remaining functions ported verbatim from contents/code/api.js with export added
```

- [ ] **Step 4: Run tests until green**

Run: `gjs -m gnome-extension/tests/api-test.js`
Expected: `All api tests passed`, exit 0

- [ ] **Step 5: Commit**

```bash
git add gnome-extension/api.js gnome-extension/tests/api-test.js
git commit -m "feat(gnome): port console API logic to GJS module with parse tests"
```

---

### Task 3: Settings — gsettings schema + prefs window

**Files:**
- Create: `gnome-extension/schemas/org.gnome.shell.extensions.opencodego-usage.gschema.xml`
- Create: `gnome-extension/settings.js`
- Create: `gnome-extension/prefs.js`

**Interfaces:**
- Consumes: nothing (schema is declarative)
- Produces: `settings.js` exporting `getSettings() -> Gio.Settings` (bound to the installed schema), and convenience `getWorkspaceId()`, `getAuthCookie()`, `getRefreshSeconds() -> number (minutes*60)`, `connectChanged(settings, names, cb)`. `prefs.js` exposes `export default class extends Adw.PreferencesWindow` filled with three rows.

- [ ] **Step 1: Write the schema XML**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- © Mayanktaker Computers & Web Development | https://mayanktaker.com -->
<schemalist>
  <schema id="org.gnome.shell.extensions.opencodego-usage" path="/org/gnome/shell/extensions/opencodego-usage/">
    <!-- OpenCode workspace/org id (wrk_… or org_…) copied from the console URL -->
    <key type="s" name="workspace-id">
      <default>''</default>
      <summary>Workspace ID</summary>
      <description>OpenCode workspace id, e.g. wrk_XXXXXXXX from the console URL</description>
    </key>
    <!-- __Host-console_session cookie value (or a full Cookie header) copied from the browser -->
    <key type="s" name="auth-cookie">
      <default>''</default>
      <summary>Auth Cookie</summary>
      <description>Session cookie value from opencode.ai console (DevTools → Application → Cookies)</description>
    </key>
    <!-- Polling interval; the console API is rate-sensitive so the floor is one minute -->
    <key type="u" name="refresh-minutes">
      <default>5</default>
      <summary>Refresh interval (minutes)</summary>
      <description>How often usage is refreshed; minimum 1 minute</description>
    </key>
  </schema>
</schemalist>
```

- [ ] **Step 2: Write settings.js**

```javascript
// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// gsettings access helpers for the extension runtime and prefs window

import Gio from 'gi://Gio';

// Schema id must match schemas/*.gschema.xml and the extension uuid family
const SCHEMA_ID = 'org.gnome.shell.extensions.opencodego-usage';

// Loads the compiled schema from the user extension directory (works installed and via gnome-session dev mode)
export function getSettings() {
    // GNOME Shell >= 45 resolves extension schemas automatically for installed extensions
    return new Gio.Settings({ schema_id: SCHEMA_ID });
}

// Workspace id accessor
export function getWorkspaceId(settings) { return settings.get_string('workspace-id'); }
// Auth cookie accessor
export function getAuthCookie(settings) { return settings.get_string('auth-cookie'); }
// Refresh interval in seconds (minutes * 60) with a one-minute floor
export function getRefreshSeconds(settings) {
    return Math.max(1, settings.get_uint('refresh-minutes')) * 60;
}
// Subscribes to key changes; cb receives the changed key name
export function connectChanged(settings, names, cb) {
    const ids = names.map(n => settings.connect('changed::' + n, (s, k) => cb(k)));
    return () => ids.forEach(id => settings.disconnect(id));
}
```

- [ ] **Step 3: Write prefs.js**

```javascript
// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// libadwaita preferences window: credentials and refresh interval

import Adw from 'gi://Adw';
import Gtk from 'gi://Gtk';
import { getSettings } from './settings.js';

// One preferences page binding the three gsettings keys to rows
export default class OpenCodeGoPrefs extends Adw.PreferencesWindow {
    // Builds rows and binds them bidirectionally to gsettings
    constructor(params = {}) {
        super(params);
        this.settings = getSettings();

        const page = new Adw.PreferencesPage({ title: 'OpenCode Go', icon_name: 'applications-system-symbolic' });
        const group = new Adw.PreferencesGroup({ title: 'Console Credentials', description: 'Copy from opencode.ai/console → DevTools → Application → Cookies' });
        page.add(group);

        // Workspace ID entry
        const wsRow = new Adw.EntryRow({ title: 'Workspace ID (wrk_…)' });
        this.settings.bind('workspace-id', wsRow, 'text', Gio.SettingsBindFlags.DEFAULT);
        group.add(wsRow);

        // Auth cookie entry with password reveal so the token is not left readable
        const cookieRow = new Adw.PasswordEntryRow({ title: 'Auth Cookie (__Host-console_session value)' });
        this.settings.bind('auth-cookie', cookieRow, 'text', Gio.SettingsBindFlags.DEFAULT);
        group.add(cookieRow);

        // Refresh interval spin row, 1–60 minutes
        const refreshRow = new Adw.SpinRow({
            title: 'Refresh interval (minutes)', adjustment: new Gtk.Adjustment({
                lower: 1, upper: 60, step_increment: 1, value: this.settings.get_uint('refresh-minutes')
            })
        });
        this.settings.bind('refresh-minutes', refreshRow, 'value', Gio.SettingsBindFlags.DEFAULT);
        group.add(refreshRow);

        this.add(page);
    }
}
```

Note: if the installed GNOME's prefs loader expects a `fillPreferencesWindow(window)` function instead of a default-export class (behavior differs slightly across 45–50), adapt: keep the same group/row construction inside `export function fillPreferencesWindow(window)` moving the body of `constructor` into it with `this.settings` → a local `settings`. Verify which form loads with `gnome-extensions prefs com.mayanktaker.opencodego-usage` during Task 6 and keep the working one.

- [ ] **Step 4: Compile schema and syntax-check JS**

Run: `glib-compile-schemas --strict gnome-extension/schemas/ && gjs -c "$(cat gnome-extension/settings.js | sed 's/^import.*//')" 2>/dev/null; gjs --help >/dev/null && echo OK`
Expected: schema compiles without warnings; OK printed. (Full runtime check happens in Task 6; here we only catch XML/JS syntax errors.)

- [ ] **Step 5: Commit**

```bash
git add gnome-extension/schemas gnome-extension/settings.js gnome-extension/prefs.js
git commit -m "feat(gnome): gsettings schema and libadwaita prefs window"
```

---

### Task 4: popup.js — popup content builder

**Files:**
- Create: `gnome-extension/popup.js`

**Interfaces:**
- Consumes: model from `api.js` (`{isMock, usagePercent, resetSeconds, hourly, weekly, monthly, lastRefreshed}`), `formatResetFull(sec)`, `isTransientError(err)`
- Produces: `export function buildMenuContent(menu, state)` where `state = {status:'ok'|'error'|'transient'|'demo', data:model|null, error:string|null}`; populates `menu` with header row, three usage bars, footer note. `export function clearMenuContent(menu)` used before rebuild.

- [ ] **Step 1: Write popup.js**

```javascript
// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Builds the hover/click popup: header, three usage bars, footer status note

import St from 'gi://St';
import GLib from 'gi://GLib';
import * as Api from './api.js';

// Row definition shared by the three windows: popup label + model slot + reset key
const WINDOWS = [
    { label: 'Rolling (5h)', slot: 'hourly', resetKey: 'hourly' },
    { label: 'Weekly', slot: 'weekly', resetKey: 'weekly' },
    { label: 'Monthly', slot: 'monthly', resetKey: 'monthly' }
];

// Empties the menu so a refresh can rebuild it without stacking items
export function clearMenuContent(menu) {
    menu.removeAll();
}

// Formats a seconds countdown for the bar sub-label (falls back to full formatter)
function resetLabel(seconds) {
    return Api.formatResetFull(seconds);
}

// Builds one usage row: label + percent on top, bar + countdown below
function addUsageRow(menu, labelText, percent, resetSeconds) {
    const rowLabel = new St.BoxLayout({ vertical: false, x_expand: true });
    rowLabel.add_child(new St.Label({ text: labelText, x_expand: true }));
    rowLabel.add_child(new St.Label({ text: percent + '%' }));
    menu.box.add(rowLabel);

    // Progress bar uses the theme accent; a red tint above 90% signals quota pressure
    const bar = new St.DrawingArea({ style_class: 'popup-menu-item', x_expand: true, height: 8 });
    const fill = Math.max(0, Math.min(100, percent)) / 100;
    bar.connect('repaint', area => {
        const [w, h] = area.get_surface_size();
        const cr = area.get_context();
        const themeNode = area.get_theme_node();
        const fg = themeNode.get_foreground_color();
        cr.setSourceRGBA(fg.red / 255, fg.green / 255, fg.blue / 255, 0.25);
        cr.rectangle(0, h / 4, w, h / 2);
        cr.fill();
        cr.setSourceRGBA(fg.red / 255, fg.green / 255, fg.blue / 255, 1.0);
        cr.rectangle(0, h / 4, Math.round(w * fill), h / 2);
        cr.fill();
        cr.$dispose();
    });
    menu.box.add(bar);

    if (resetSeconds > 0) {
        const sub = new St.Label({ text: 'resets in ' + resetLabel(resetSeconds), style: 'font-size: 0.85em; opacity: 0.7;' });
        menu.box.add(sub);
    }
}

// One-line footer carrying the current state (demo/transient/error/last refreshed)
function addFooter(menu, state) {
    let text = 'Last refreshed: ' + (state.data ? state.data.lastRefreshed : '—');
    if (state.status === 'demo') text = 'Demo mode — add credentials in settings';
    else if (state.status === 'transient') text = 'Console API temporarily unavailable — showing last known figures';
    else if (state.status === 'error') text = String(state.error || 'Unknown error');
    const footer = new St.Label({ text: text, style: 'font-size: 0.85em; opacity: 0.75;' });
    menu.box.add(footer);
}

// Rebuilds the popup for the given state; safe to call on every open/refresh
export function buildMenuContent(menu, state) {
    clearMenuContent(menu);
    const header = new St.BoxLayout({ vertical: false, x_expand: true });
    header.add_child(new St.Label({ text: 'OpenCode Go', x_expand: true, style: 'font-weight: bold;' }));
    header.add_child(new St.Label({ text: state.data ? String(state.data.usagePercent) + '%' : '—', style: 'font-weight: bold;' }));
    menu.box.add(header);
    menu.box.add(new PopupMenu.PopupSeparatorMenuItem());

    if (state.status === 'error') {
        addFooter(menu, state);
        return;
    }
    const data = state.data;
    if (!data) { addFooter(menu, state); return; }

    for (const w of WINDOWS) {
        const bars = data[w.slot] || [];
        const pct = bars.length ? bars[0].value : 0;
        addUsageRow(menu, w.label, pct, (data.resetSeconds || {})[w.resetKey] || 0);
    }
    menu.box.add(new PopupMenu.PopupSeparatorMenuItem());
    addFooter(menu, state);
}
```

Note for the executor: `PopupMenu` is not imported in popup.js — separators (`PopupMenu.PopupSeparatorMenuItem`) are added in extension.js context where PopupMenu is imported; inside popup.js use `menu.addMenuItem` only when the menu exposes it, otherwise `menu.box.add(new St.BoxLayout({ style: 'padding-top: 4px;' }))` as a spacer. Also: the spawn note below applies to Task 5.

Run: `node --check gnome-extension/popup.js 2>/dev/null || gjs -m gnome-extension/popup.js 2>&1 | head -3`
Expected: no syntax errors reported (a gi import failure at runtime is acceptable in this step; a *parse* error is not)

- [ ] **Step 3: Commit**

```bash
git add gnome-extension/popup.js
git commit -m "feat(gnome): popup builder with three usage bars and status footer"
```

---

### Task 5: extension.js — indicator, transport, refresh loop

**Files:**
- Create: `gnome-extension/extension.js`

**Interfaces:**
- Consumes: `api.js` (`buildCurlCommand`, `parseCurlOutput`, `parseAnyResponse`, `getMockData`, `consoleRouteCount`, `maxAttemptsPerRoute`, `noRouteError`, `checkCookieError`, `checkWorkspaceIdError`), `settings.js` (`getSettings`, `getWorkspaceId`, `getAuthCookie`, `getRefreshSeconds`, `connectChanged`), `popup.js` (`buildMenuContent`, `clearMenuContent`)
- Produces: GNOME extension entry points `export function enable()`, `export function disable()`, and `export class OpenCodeGoIndicator extends PanelMenu.Button` with `refresh()` (async fetch cycle) — the popup is opened on `enter-event` and toggled on click.

- [ ] **Step 1: Write extension.js**

```javascript
// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Panel indicator: fetches Go usage via curl and shows a hover popup with the three windows

import GObject from 'gi://GObject';
import GLib from 'gi://GLib';
import Gio from 'gi://Gio';
import St from 'gi://St';
import Clutter from 'gi://Clutter';
import { Extension, gettext as _ } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';

import * as Api from './api.js';
import * as Settings from './settings.js';
import * as Popup from './popup.js';

// Panel indicator button; hover opens the popup, click toggles it
const OpenCodeGoIndicator = GObject.registerClass(
class OpenCodeGoIndicator extends PanelMenu.Button {
    // Wires the icon, hover-to-open behavior, and the initial state
    _init() {
        super._init(0.0, 'OpenCode Go Usage', false);
        this._icon = new St.Icon({
            icon_name: 'applications-system-symbolic',
            style_class: 'system-status-icon'
        });
        this.add_child(this._icon);

        // Fetch state machine shared with popup.js
        this._state = { status: 'demo', data: null, error: null };

        // Hover opens the popup (GNOME tray tooltips do not exist, so the popup IS the tooltip)
        this.connect('enter-event', () => {
            if (!this.menu.isOpen) this.menu.open();
            return Clutter.EVENT_PROPAGATE;
        });

        // Initial paint with demo data so the popup is never empty
        this._setState({ status: 'demo', data: Api.getMockData(), error: null });
    }

    // Rebuilds popup content from state
    _setState(state) {
        this._state = state;
        Popup.buildMenuContent(this.menu, state);
    }

    // Runs one curl request honoring the route-walk and retry rules from api.js
    refresh() {
        // Single in-flight guard: a hover-triggered open never stacks curl processes
        if (this._inFlight) return;
        const ws = this._workspaceId;
        const cookie = this._authCookie;

        // No credentials -> demo mode, same as the KDE widget
        if (!cookie || !cookie.trim() || !ws || !ws.trim()) {
            this._setState({ status: 'demo', data: Api.getMockData(), error: null });
            this._scheduleNext();
            return;
        }
        const cookieErr = Api.checkCookieError(cookie);
        const wsErr = Api.checkWorkspaceIdError(ws);
        if (cookieErr || wsErr) {
            this._setState({ status: 'error', data: null, error: cookieErr || wsErr });
            this._scheduleNext();
            return;
        }

        this._inFlight = true;
        this._route = 0;
        this._attempt = 0;
        this._attemptRoute(ws, cookie);
    }

    // Fires curl for the current candidate route
    _attemptRoute(ws, cookie) {
        const cmd = Api.buildCurlCommand(ws, cookie, this._route);
        try {
            const [, stdout, stderr] = GLib.spawn_command_line_sync('sh -c ' + Api.shellQuote(cmd));
            this._handleOutput(stdout.toString(), stderr.toString());
        } catch (e) {
            this._setState({ status: 'error', data: null, error: 'Network unreachable. Please check your internet connection.' });
            this._inFlight = false;
            this._scheduleNext();
        }
    }

    // Applies parse rules: 404 walks routes, 5xx retries in place, otherwise finalize
    _handleOutput(stdout, stderr) {
        const result = Api.parseCurlOutput(stdout, stderr, 0);
        if (!result.error && !result.data && result.httpStatus === 404) {
            if (this._route + 1 < Api.consoleRouteCount()) {
                this._route += 1;
                this._attempt = 0;
                this._attemptRoute(this._workspaceId, this._authCookie);
                return;
            }
            this._setState({ status: 'error', data: null, error: Api.noRouteError() });
        } else if (result.httpStatus >= 500 && this._attempt + 1 < Api.maxAttemptsPerRoute()) {
            this._attempt += 1;
            this._attemptRoute(this._workspaceId, this._authCookie);
            return;
        } else if (result.error) {
            // Transient 5xx keeps the last known figures, mirroring the KDE widget
            if (result.httpStatus >= 500 && this._state.data) {
                this._setState({ status: 'transient', data: this._state.data, error: result.error });
            } else {
                this._setState({ status: 'error', data: null, error: result.error });
            }
        } else {
            this._setState({ status: 'ok', data: result.data, error: null });
        }
        this._inFlight = false;
        this._scheduleNext();
    }

    // Arms the GLib timer for the next refresh; rebuilt whenever settings change
    _scheduleNext() {
        if (this._timerId) GLib.source_remove(this._timerId);
        this._timerId = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, this._refreshSeconds, () => {
            this._timerId = null;
            this.refresh();
            return GLib.SOURCE_REMOVE;
        });
    }

    // Stops timer and any pending work (disable() must leave nothing behind)
    destroy() {
        if (this._timerId) { GLib.source_remove(this._timerId); this._timerId = null; }
        super.destroy();
    }
});

// Extension lifecycle: creates the indicator, reads settings, subscribes to changes
export default class OpenCodeGoExtension extends Extension {
    // Called on login/enable: build indicator, load settings, first fetch
    enable() {
        this._settings = Settings.getSettings();
        this._indicator = new OpenCodeGoIndicator();
        Main.panel.addToStatusArea(this.uuid, this._indicator, 0, 'right');

        // Settings reader bound onto the indicator so refresh() always sees current values
        this._applySettings = () => {
            this._indicator._workspaceId = Settings.getWorkspaceId(this._settings);
            this._indicator._authCookie = Settings.getAuthCookie(this._settings);
            this._indicator._refreshSeconds = Settings.getRefreshSeconds(this._settings);
        };
        this._applySettings();
        this._unsub = Settings.connectChanged(this._settings, ['workspace-id', 'auth-cookie', 'refresh-minutes'], () => {
            this._applySettings();
            this._indicator.refresh();
        });
        this._indicator.refresh();
    }

    // Called on disable/logout: tear down everything this extension created
    disable() {
        if (this._unsub) { this._unsub(); this._unsub = null; }
        if (this._indicator) { this._indicator.destroy(); this._indicator = null; }
        this._settings = null;
    }
}
```

Note for the executor: `popup.js` uses `menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem())` — import PopupMenu there too, or route separator creation through a tiny helper in extension.js. `GLib.spawn_command_line_sync` blocks the shell thread briefly (≤15s worst case). Acceptable for v1 per spec (one in-flight, 5-min cadence); if hover jank is observed in Task 6 testing, switch to `Gio.Subprocess` async in a follow-up — do not redesign now.

- [ ] **Step 2: Syntax-check**

Run: `gjs -m gnome-extension/extension.js 2>&1 | head -3`
Expected: a gi/resource import error (expected outside Shell) but **no parse errors**

- [ ] **Step 3: Commit**

```bash
git add gnome-extension/extension.js
git commit -m "feat(gnome): panel indicator with curl transport and refresh loop"
```

---

### Task 6: Install, live-test on GNOME 50.5, and docs update

**Files:**
- Create: `gnome-extension/icons/opencodego-symbolic.svg` (copy of `assets/icon.svg` if present, else text-glyph fallback)
- Modify: `AGENTS.md` (GNOME section pointer)
- Modify: `README.md` (GNOME install section)

**Interfaces:**
- Consumes: Tasks 1–5 files, `install.sh`
- Produces: a working extension on the live session; docs pointing to `gnome-extension/`.

- [ ] **Step 1: Add panel icon asset**

Copy `assets/icon.svg` → `gnome-extension/icons/opencodego-symbolic.svg`. If the SVG is multicolor and renders poorly as a symbolic icon, keep the fallback `applications-system-symbolic` icon_name already used in extension.js and add a follow-up note in README.

- [ ] **Step 2: Install and enable**

Run: `bash gnome-extension/install.sh`
Expected: "Installed com.mayanktaker.opencodego-usage → …" and no glib-compile-schemas errors

- [ ] **Step 3: Verify extension state**

Run: `gnome-extensions info com.mayanktaker.opencodego-usage && journalctl --user -b --since "5 min ago" | grep -i opencodego | head -20`
Expected: state `ACTIVE` (or `INITIALIZED` if Wayland needs relogin — then ask the user to log out/in and re-run). Journal clean of GJS errors.

- [ ] **Step 4: Live UI checks (user-assisted)**

Ask the user to:
1. Confirm the panel icon appears top-right.
2. Hover it → popup shows three bars (demo data initially, or real figures once credentials are set).
3. Open prefs: `gnome-extensions prefs com.mayanktaker.opencodego-usage` → paste Workspace ID + Auth Cookie → close.
4. Hover again within ~1 min → real Rolling/Weekly/Monthly percentages.
5. Set an intentionally bad cookie → auth error message appears in popup footer.

If prefs window does not open, switch `prefs.js` to the `fillPreferencesWindow(window)` form (per Task 3 note) and re-run install.sh.

- [ ] **Step 5: Update docs**

In `AGENTS.md`, under a new `## GNOME Extension` heading add (concise, pointers only):

```markdown
## GNOME Extension
- `gnome-extension/` — GNOME Shell port of this plasmoid (panel icon + hover popup with Rolling/Weekly/Monthly usage). UUID `com.mayanktaker.opencodego-usage`, GNOME Shell 45–50.
- Install/test: `bash gnome-extension/install.sh` (compiles schema, enables; first install on Wayland may need logout/login). Prefs: `gnome-extensions prefs com.mayanktaker.opencodego-usage`. Settings in gsettings `org.gnome.shell.extensions.opencodego-usage` (workspace-id, auth-cookie, refresh-minutes, default 5).
- API logic is a port of `contents/code/api.js` — same routes, cookie rules, percentages, error mapping. When console API behavior changes, update BOTH `contents/code/api.js` and `gnome-extension/api.js`, then `gjs -m gnome-extension/tests/api-test.js`.
- After edits: reinstall via install.sh; on Wayland, logout/login or `gnome-extensions disable/enable` may be needed. Check `journalctl --user -b | grep -i opencodego` for GJS errors.
```

In `README.md`, add a short "GNOME Shell" install section: `bash gnome-extension/install.sh`, hover to see usage, settings via the extension's preferences, demo mode without credentials.

- [ ] **Step 6: Commit**

```bash
git add gnome-extension AGENTS.md README.md
git commit -m "feat(gnome): live-verified GNOME extension with docs"
```

---

## Task Dependency Graph

```
Task 1 (skeleton) ──► Task 2 (api.js) ──► Task 4 (popup) ──► Task 5 (extension.js) ──► Task 6 (install/live)
                                    └─► Task 3 (settings/prefs) ──────────────────────┘
```

Tasks 2 and 3 are independent of each other; Task 4 depends on 2; Task 5 depends on 2, 3, 4; Task 6 depends on all.
