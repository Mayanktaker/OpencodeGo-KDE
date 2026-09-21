# OpenCode Go Usage — GNOME Shell Extension Design

© Mayanktaker Computers & Web Development | https://mayanktaker.com

## Goal

A GNOME Shell extension that mirrors the KDE plasmoid's OpenCode Go usage tracking:
a panel icon (the `O✦` cyan-teal logo) that shows a popup with Rolling (5h),
Weekly, and Monthly usage on hover. Lives in `gnome-extension/` inside this repo,
side by side with the KDE plasmoid.

- Target: GNOME Shell 45–50 (author runs GNOME 50.5 on Wayland)
- Distribution: installed via `gnome-extension/install.sh` into
  `~/.local/share/gnome-shell/extensions/com.mayanktaker.opencodego-usage/`

## Decisions (approved in chat)

| Decision | Choice |
|---|---|
| Interaction | Custom panel indicator; hover opens popup (click too). AppIndicator rejected — GNOME tray tooltips unsupported. |
| Location | `gnome-extension/` in this repo |
| Credentials | gsettings schema + libadwaita prefs window |
| Refresh | Configurable via gsettings, default 5 min |

## Architecture

```
gnome-extension/
├── metadata.json            # uuid com.mayanktaker.opencodego-usage, shell-version ["45".."50"]
├── extension.js             # panel indicator, hover/click popup, refresh timer
├── popup.js                 # popup content builder: 3 bars, countdowns, status/error notes
├── settings.js              # gsettings helpers (get/set, changed signals)
├── prefs.js                 # libadwaita settings window
├── api.js                   # GJS ESM port of contents/code/api.js
├── schemas/
│   └── org.gnome.shell.extensions.opencodego-usage.gschema.xml
└── install.sh               # copy + glib-compile-schemas + enable
```

### api.js (ported, not re-implemented)

Port `contents/code/api.js` to a GJS ES module. Preserved exactly:

- `CONSOLE_STATUS_ROUTES` route list; walk on 404 only
- `buildCookieHeader` / cookie normalization (`KNOWN_COOKIE_NAMES`, quote
  stripping, `Fe26` → `auth=`, bare value → `__Host-console_session=`,
  min 16-char value)
- `buildCurlCommand`: curl with `Cookie`, `User-Agent`, `Accept: application/json`,
  `x-org-id`, `Referer`, `--max-time 15`, `-w HTTPSTATUS:%{http_code}`
- `parseCurlOutput` semantics: 404 → next route, 400/401/403 → final errors,
  5xx → retry same route (3 attempts), then "temporarily unavailable"
- `parseConsoleGoStatus`: `access.meters.fiveHour/week/month`,
  micro-cents via `toMicroCents` (BigInt-as-string), `meterPercent`
  (`floor((used*200+limit)/(limit*2))` clamped), `secondsUntil` for resets
  (month resets at `access.endsAt`)
- `getMockData` demo mode when credentials empty
- Error text strings identical to the KDE widget

Differences from the QML host: transport runs curl via
`Gio.Subprocess` (synchronous-safe async callback), not the Plasma
dataengine. One request in flight at a time; a new refresh tick skips if
one is pending.

### extension.js

- `PanelMenu.Button` subclass placed at the right of the panel.
- Icon: the `O✦` SVG (`gnome-extension/icons/opencodego-symbolic.svg` or
  reuse of `assets/icon.svg` tinted for panel use; fallback text glyph if
  icon loading fails).
- `enter-event` on the actor opens the popup; `button-press-event` toggles
  it as well. Popup closes on leave/escape/outside click (default Menu
  behavior).
- Timer: `GLib.timeout_add_seconds(refreshMinutes * 60)`; interval read
  from gsettings, timer rebuilt on change. One immediate refresh at enable.
- State model: `{ status: 'ok'|'error'|'transient'|'demo', data, error }`
  handed to popup.js for rendering.

### popup.js

Popup layout (top to bottom):

1. Header: "OpenCode Go" + last-refreshed time
2. Three rows — Rolling (5h) / Weekly / Monthly: label, horizontal progress
  bar (theme-colored fill, red tint > 90%), percentage, reset countdown
  ("resets in 3h 12m"); month row shows period end from `access.endsAt`.
3. Footer note area: transient 5xx → "showing last known figures", auth
  error → update-cookie message, demo mode → demo notice.

### Schemas

```
workspace-id      s  ""   OpenCode workspace/org id (wrk_…/org_…)
auth-cookie       s  ""   __Host-console_session cookie value or full header
refresh-minutes   u  5    Refresh interval in minutes (min 1)
```

`auth-cookie` is readable only by the user account anyway (dconf is
per-user); stored as-is like the KDE config does.

### prefs.js

libadwaita `Adw.PreferencesWindow`: entries for Workspace ID and Auth
Cookie (password-style entry with reveal), spin row for refresh minutes,
demo-mode hint text. Same validation hints as KDE (cookie ≥16 chars,
`wrk_`/`org_` workspace id).

### install.sh

1. `mkdir -p ~/.local/share/gnome-shell/extensions/com.mayanktaker.opencodego-usage`
2. rsync/cp extension files (excluding install.sh)
3. `glib-compile-schemas` the schemas dir into the installed copy
4. `gnome-extensions enable com.mayanktaker.opencodego-usage`
5. Print a note: Wayland users may need to log out/in for a fresh install
   to appear (enable works live only if extension is already known to the
   shell).

## Error handling

Same mapping as the KDE widget:

| Condition | Surface |
|---|---|
| 401 `_tag: Unauthorized` | "Auth Cookie is invalid or expired…" |
| 403 `_tag: Forbidden` | restricted route message |
| 400 | "check the Workspace ID" |
| 404 on all routes | "route not found — check for an extension update" |
| 5xx ×3 | transient; keep last known figures + note |
| network/timeout | clean network message |
| no credentials | demo mode (mock data), clearly labeled |

## Testing

1. `gjs -m gnome-extension/tests/api-test.js`: feed captured fixtures
   (console JSON shape, `_tag` errors, HTML shells) through `parseCurlOutput`
   and assert the model — no shell/network needed.
2. `bash gnome-extension/install.sh` on the running GNOME 50.5 session.
3. Live checks: panel icon visible; hover shows popup with real figures;
   bad cookie → auth message; `refresh-minutes` change takes effect.
4. `gnome-extensions info com.mayanktaker.opencodego-usage` and
   `journalctl --user -b | grep opencodego` free of GJS errors.

## Out of scope (YAGNI)

- Click-through menu actions (open console in browser) — can be added later
- AppIndicator fallback variant
- Hourly bar charts from the KDE full representation
