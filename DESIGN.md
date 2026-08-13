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
8. **Reset countdown** — always show when the quota resets

---

## 📐 Widget Layout Structure

```
┌───────────────────────────────────────────┐
│ [<O✦>] OpenCode Go               [🔄]     │  ← Full-bleed header (headerBackgroundColor)
│        Usage Tracker                       │
├───────────────────────────────────────────┤  ← 1px hairline divider
│ Usage resets in 4 Days                    │  ← Section Header
│                                           │
│ Rolling                               14% │  ← Row 1: label + percentage
│ [████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] │  ← Progress bar
│                                           │
│ Weekly                                37% │  ← Row 2
│ [███████████████████░░░░░░░░░░░░░░░░░░░] │
│                                           │
│ Monthly                               80% │  ← Row 3 (highlighted gold ≥80%)
│ [███████████████████████████████████░░░] │
│                                           │
│ Last updated: 7:15:48 PM | Time Zone      │  ← Footer: timestamp
└───────────────────────────────────────────┘
```

---

## 🎨 Color System

### Per-Window Colors (distinct for quick scanning)
| Window | Color | Rationale |
|--------|-------|-----------|
| Rolling | `Qt.alpha(textColor, 0.6)` | Muted — short-term, least critical |
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
    <entry name="showTitle" type="Bool"><default>true</default></entry>
    <entry name="showBorder" type="Bool"><default>false</default></entry>
    <!-- Theme colors: backgroundColor, textColor, barColor, barSecondaryColor, accentColor -->
</group>
```

### Config Dialog Tabs
1. **General** — workspace ID, auth cookie, refresh interval, notifications, bar icons toggle
2. **Appearance** — theme presets, custom color pickers
3. **Credits & Support** — developer info, donation links
4. **About** — KDE built-in from metadata.json

---

## 🌐 Data Fetching Pattern

### Transport: curl via Plasma executable engine
Qt's QML `XMLHttpRequest` silently strips the `Cookie` header (Qt `CookieLoadControlAttribute`). The workaround:

```
UsageFetcher.qml
  → buildCurlCommand() in api.js (shell-quoted cookie)
  → Plasma DataSource "executable" engine runs curl
  → onNewData: stdout → parseCurlOutput() → parseAnyResponse()
  → callback(err, data) → main.qml state update
```

### Endpoints
| Provider | Endpoint | Auth |
|----------|----------|------|
| OpenCode Go | `https://opencode.ai/workspace/{id}/go` | Cookie: `auth=<token>` |
| z.ai | `https://z.ai/workspace/{id}/go` | Cookie: `auth=<token>` (TBD) |

### Response Parsing
1. **SolidJS store** (primary): regex extract `rollingUsage/weeklyUsage/monthlyUsage` with `usagePercent` and `resetInSec`
2. **Next.js `__NEXT_DATA__`** (fallback): JSON parse embedded script block
3. **Generic regex** (last resort): extract first `usagePercent` value

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
