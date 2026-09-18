<!-- © Mayanktaker Computers & Web Development | https://mayanktaker.com -->
# Design & Settings Guide — Shared UI/UX Patterns

This document defines the reusable UI patterns, settings architecture, and data-fetching approach used across Mayanktaker's AI usage tracker widgets (OpenCode Go, z.ai, and future products).

---

## 🎯 Design Principles

1. **Brand Identity Logo (`<O✦>`)** — vector cyan-teal code brackets `< >` enclosing center ring `O` and glowing spark `✦`
2. **Full-bleed Header Title Block** — top header area styled with separate `headerBackgroundColor`, spans full widget width with top corners matching the card radius, separated from content by a 1px hairline
3. **Compact by default** — widget height Hugs content tightly without leftover bottom padding
4. **Color-coded bars** — each usage window gets a distinct text color for quick visual scanning with amber highlights for high usage (≥ 80%)
5. **Gradient depth** — smooth horizontal cyan gradient fills on progress bars
6. **Minimal chrome** — percentage text aligned on top right of progress bar rows
7. **Horizontal-only layout** — single layout mode, no tabbed/all-in-one complexity
8. **Reset countdown** — always show when the quota resets; per-window "reset in X" brackets next to Rolling (5h)/Weekly/Monthly are toggleable in settings

---

## 📐 Widget Layout Structure

```
┌────────────────────────────────────────────────────┐
│ [<O✦>] OpenCode Go               [🔄]               │  ← Full-bleed header (headerBackgroundColor)
│        Usage Tracker                               │
├────────────────────────────────────────────────────┤  ← 1px hairline divider
│                                                    │
│ Rolling (5h) (reset in 3 hours 45 minutes)  14%    │  ← Row 1: label + reset bracket + percentage
│ [████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░]          │  ← Progress bar
│                                                    │
│ Weekly (reset in 4 days 7 hours)       37%         │  ← Row 2
│ [███████████████████░░░░░░░░░░░░░░░░░░░]           │
│                                                    │
│ Monthly (reset in 19 days 5 hours)     80%         │  ← Row 3 (highlighted gold ≥80%)
│ [███████████████████████████████████░░░]           │
│                                                    │
│ Last updated: 7:15:48 PM | Time Zone               │  ← Footer: timestamp
└────────────────────────────────────────────────────┘
```

---

## 🎨 Color System

### Per-Window Colors (distinct for quick scanning)
| Window | Color | Rationale |
|--------|-------|-----------|
| Rolling (5h) | `Qt.alpha(textColor, 0.6)` | Muted — short-term, least critical |
| Weekly | `accentColor` | Prominent — main quota window |
| Monthly | `"#ffb86c"` | Warning — long-term, shows trend |

### Badge Colors (removed from header, used in bar % text)
| Usage % | Color | Hex |
|---------|-------|-----|
| < 75% | Window-specific (above) | — |
| 75-89% | Warning Orange | `#ffb86c` |
| ≥ 90% | Critical Red | `#ff5555` |

### Background Gradients
- **Widget background**: top = `Qt.lighter(bg, 1.08)`, bottom = `Qt.darker(bg, 1.05)`
- **Bar tracks**: top = `Qt.darker(bg, 1.2)`, bottom = `Qt.darker(bg, 1.5)`

---

## ⚙️ Settings Architecture

### main.xml (KDE Config Schema)
```xml
<group name="General">
    <entry name="workspaceId" type="String" />
    <entry name="authCookie" type="String" />
    <entry name="refreshInterval" type="Int"><default>60000</default></entry>
    <entry name="enableNotifications" type="Bool"><default>true</default></entry>
    <entry name="notificationThreshold" type="Int"><default>80</default></entry>
</group>
<group name="Appearance">
    <entry name="showBarIcons" type="Bool"><default>false</default></entry>
    <entry name="showResetTimes" type="Bool"><default>true</default></entry>
    <entry name="showTitle" type="Bool"><default>true</default></entry>
    <entry name="showBorder" type="Bool"><default>false</default></entry>
    <!-- Theme colors: backgroundColor, textColor, barColor, barSecondaryColor, accentColor -->
</group>
```

### Config Dialog Tabs
1. **General** — workspace ID, auth cookie, refresh interval, notifications
2. **Appearance** — theme presets, custom color pickers, title/border toggles, bar icons, per-window reset countdown
3. **Credits & Support** — developer info, donation links
4. **About** — KDE built-in from metadata.json

---

## 🌐 Data Fetching Pattern

### Transport: curl via Plasma executable engine
Qt's QML `XMLHttpRequest` silently strips the `Cookie` header (Qt `CookieLoadControlAttribute`). The workaround:

```
UsageFetcher.qml
  → buildCurlCommand(ws, cookie, routeIndex) in api.js (shell-quoted cookie, curl -w HTTPSTATUS:%{http_code})
  → Plasma DataSource "executable" engine runs curl (HTTP 404 → next candidate route)
  → onNewData: stdout → splitHttpStatus() → parseCurlOutput() → parseAnyResponse()
  → callback(err, data) → main.qml state update
```

### Endpoints
| Provider | Endpoint | Auth |
|----------|----------|------|
| OpenCode Go | Primary: `GET https://opencode.ai/console/api/go/status` (no org in path). Fallback candidates: `https://opencode.ai/console/api/internal/orgs/{orgId}/go/status` (**support-staff only** — HTTP 403 for a regular account), then `/console/api/orgs/{orgId}/go/status`, `/console/api/v2/orgs/{orgId}/go/status`, `/console/api/v1/orgs/{orgId}/go/status` | Cookie: `__Host-console_session=<token>` — **required** header `x-org-id: {orgId}` (+ `Accept: application/json`, `Referer`) |
| z.ai | `https://z.ai/workspace/<id>/go` | Cookie: `auth=<token>` (TBD) |

1. **Console JSON** (OpenCode Go): the primary route takes **no org in the path** — the workspace id must be sent in the `x-org-id` header or the server answers HTTP 400 `{"_tag":"BadRequest"}`; the `/console/api/internal/orgs/{orgId}/go/status` variant is support-staff-only and 403s for a regular account. Parse `access.meters.fiveHour` / `week` / `month` → Rolling (5h) / Weekly / Monthly window; percent = `floor((used*200 + limit) / (limit*2))`, clamped to 0..100; `month` resets at `access.endsAt`.
2. **`{"_tag":"Unauthorized"}`** (HTTP 401): session expired → ask for a fresh `__Host-console_session` cookie value (the legacy `auth=Fe26.2**` seal no longer authenticates). Final — no route retry. HTTP 403 `{"_tag":"Forbidden"}` = restricted/support-only route (final); HTTP 400 `{"_tag":"BadRequest"}` = missing or bad `x-org-id` (final).
3. **HTTP 5xx** (usually `{"_tag":"InternalServerError"}`): transient — the endpoint is currently intermittent, so the SAME route is retried up to 3 attempts total and then reported as "Console API temporarily unavailable (HTTP 5xx) — retry shortly".
4. **HTTP 404 (empty body)**: this candidate route is no longer served → advance to the next candidate route (curl is called with `-w 'HTTPSTATUS:%{http_code}'` and the marker is split off the LAST occurrence in stdout). When every candidate 404s, report "OpenCode Console API route not found. The endpoint may have moved — check for a widget update."
5. **HTML fallback**: OpenAuth login page or any non-JSON body → clear "cookie invalid/expired" message instead of a parse error.

---

## 🔔 Notification Pattern

```javascript
// In main.qml callback:
if (notifyEnabled && usagePercent >= threshold && lastAlertedPercent < threshold) {
    lastAlertedPercent = usagePercent;
    Plasmoid.showNotification(title, msg, "dialog-warning");
}
```

Threshold resets when usage drops below threshold (avoids re-alerting).

---

## 📁 Shared File Structure

```
contents/
├── config/
│   ├── config.qml          # Tab model (General, Appearance, Credits)
│   └── main.xml            # KCFG schema (all settings)
├── ui/
│   ├── main.qml            # Root PlasmoidItem, timer, data flow
│   ├── UsageFetcher.qml    # curl transport via executable engine
│   ├── UsageHeader.qml     # Title + refresh + subtitle
│   ├── HorizontalUsageBars.qml  # Progress bars with colored %
│   ├── FullRepresentation.qml   # Popup container
│   ├── CompactRepresentation.qml # Panel badge
│   ├── configGeneral.qml   # Settings: auth, interval, notifications
│   ├── configAppearance.qml # Themes, colors
│   └── configAbout.qml     # Credits, donation
└── code/
    └── api.js              # buildCurlCommand, parseAnyResponse, helpers
```

---

## 🔧 Reusable Components for Future Widgets

| Component | Purpose | Reuse |
|-----------|---------|-------|
| `UsageFetcher.qml` | curl transport | Copy as-is, change endpoint |
| `api.js` (buildCurlCommand) | Shell-safe curl builder | Copy, update URL template |
| `api.js` (parseAnyResponse) | Response parser | Extend with new providers |
| `main.qml` (refreshData) | Fetch + state flow | Copy pattern, change model |
| `configGeneral.qml` | Auth settings | Copy, adjust fields |

---

## 🎯 Checklist for New AI Usage Tracker Widget

- [ ] Add endpoint to `api.js` `buildCurlCommand()` or create provider-specific parser
- [ ] Define KCFG schema in `main.xml` (workspaceId, authCookie, etc.)
- [ ] Create `configGeneral.qml` with auth fields + Test Connection button
- [ ] Use `UsageFetcher.qml` for transport (copy from this project)
- [ ] Parse response into `{ usagePercent, hourly, weekly, monthly, resetLabel }` model
- [ ] Apply gradient background + colored bar text pattern
- [ ] Add notification threshold logic
- [ ] Update `metadata.json` for KDE About page
- [ ] Create theme presets matching brand colors

---

© Mayanktaker Computers & Web Development | https://mayanktaker.com
