<!-- © Mayanktaker Computers & Web Development | https://mayanktaker.com -->
# 📊 OpenCode Go Usage Tracker — KDE Plasma 6 Plasmoid & CLI Utility

[![KDE Plasma](https://img.shields.io/badge/KDE-Plasma%206.5%2B-blue?logo=kde)](https://kde.org)
[![Qt](https://img.shields.io/badge/Qt-6.5%2B-green?logo=qt)](https://www.qt.io/)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)

A compact **KDE Plasma 6** widget and companion command-line utility for tracking your **OpenCode Go** subscription usage across **Rolling**, **Weekly**, and **Monthly** windows — right from your desktop panel.

---

## 🌟 Key Features

- 📊 **Real-Time Usage Tracking**: Fetches live data from `opencode.ai/workspace/{id}/go` via `curl` (Qt's QML XHR strips the Cookie header). Shows Rolling/Weekly/Monthly usage percentages with reset countdowns.
- 📐 **Horizontal Progress Bars**: Compact horizontal bars with animated fill, percentage badges, and hover tooltips showing detailed stats.
- 🔄 **In-Header Refresh**: One-click refresh button next to the percentage badge — no footer buttons needed.
- 🏷️ **Dynamic Panel Badge**: Real-time percentage badge on the taskbar icon with automatic color shifts:
  - `< 75%`: Configured theme accent color
  - `75% - 89%`: Warning Orange (`#ffb86c`)
  - `≥ 90%`: Critical Red (`#ff5555`)
- 🔔 **Native KDE Desktop Alerts**: System notification toasts when usage crosses your configured threshold (e.g., 80%).
- 🎨 **12 Developer Theme Presets**: Catppuccin Mocha (default), Breeze Dark, Nord, Dracula, Solarized, Gruvbox, Tokyo Night, One Dark, plus 4 light themes. Full custom color picker support.
- 💻 **Global CLI Utility (`opencode-usage`)**: Terminal access with formatted output, JSON mode (`--json`), CSV export (`--export`), and Bash/Zsh tab completions.

---

## 🖥️ System Requirements

| Component | Minimum | Recommended |
| :--- | :--- | :--- |
| **OS** | Fedora 39+, Arch, Ubuntu 24.04+, openSUSE | Any modern Linux with KDE |
| **Desktop** | KDE Plasma 6.0+ | KDE Plasma 6.5.x+ |
| **Qt** | Qt 6.5+ | Qt 6.7+ |
| **Dependencies** | `kpackagetool6`, `curl` | Pre-installed on KDE Plasma 6 |

---

## 🚀 Installation

```bash
git clone https://github.com/mayanktaker/OpencodeGo-KDE.git
cd OpencodeGo-KDE
./install.sh
```

This automatically:
1. Installs/upgrades the plasmoid to `~/.local/share/plasma/plasmoids/`
2. Registers custom icons in `~/.local/share/icons/hicolor/`
3. Purges QML caches and restarts `plasmashell`
4. Links `opencode-usage` CLI to `~/.local/bin/`
5. Installs Bash tab completions

---

## 🔑 How to Get Your Workspace ID & Auth Cookie

1. Open `https://opencode.ai` and sign in.
2. Press `F12` → **Application** → **Cookies** → `opencode.ai`.
3. Copy the `auth` cookie value (starts with `Fe26.2**`, 500+ characters).
4. Right-click the widget → **Configure** → paste **Workspace ID** and **Auth Cookie**.
5. Click **Apply** or **OK**.

---

## 💻 CLI Usage

```bash
# Display formatted usage stats
opencode-usage

# Output raw JSON
opencode-usage --json

# Export to CSV
opencode-usage --export /tmp/usage.csv

# Force demo mode
opencode-usage --demo

# Custom credentials
opencode-usage -w "ws_123" -c "auth_token"
```

---

## 📁 Project Structure

```
OpencodeGo-KDE/
├── metadata.json
├── contents/
│   ├── config/
│   │   ├── config.qml
│   │   └── main.xml
│   ├── ui/
│   │   ├── main.qml                 # Root PlasmoidItem, timer, data flow
│   │   ├── CompactRepresentation.qml # Panel tray badge
│   │   ├── FullRepresentation.qml   # Expanded popup
│   │   ├── UsageHeader.qml          # Title, refresh, percentage badge
│   │   ├── HorizontalUsageBars.qml  # Progress bars
│   │   ├── UsageBarChart.qml        # Bar chart component
│   │   ├── UsageFetcher.qml         # curl transport via executable engine
│   │   ├── ViewSelector.qml         # (disabled) tab bar
│   │   ├── configGeneral.qml        # Settings: workspace, cookie, Test button
│   │   ├── configAppearance.qml     # Theme presets & color pickers
│   │   └── configAbout.qml          # Credits & support
│   └── code/
│       └── api.js                   # Parsing, shell-quote, curl builder
├── bin/
│   ├── opencode-usage               # Python CLI client
│   ├── opencode-usage-completion.bash
│   └── opencode-usage-completion.zsh
├── assets/
│   ├── icon.svg
│   └── branding-icon.jpg
├── install.sh
├── install-cli.sh
├── AGENTS.md
├── LICENSE
└── README.md
```

---

## 🏗️ Architecture Notes

- **Network Transport**: Qt's QML XHR silently strips the `Cookie` header (Qt `CookieLoadControlAttribute`), so `UsageFetcher.qml` shells out to `curl` via Plasma's `executable` dataengine. The cookie is shell-quoted before inlining.
- **Data Parsing**: `api.js` extracts `rollingUsage`/`weeklyUsage`/`monthlyUsage` from the SolidJS store inlined in the Go page HTML. Falls back to Next.js `__NEXT_DATA__` or generic regex extraction.
- **QML Bindings**: Child components must qualify parent properties with the parent's `id` (e.g., `fullRoot.usagePercent`) — unqualified names resolve to the child's own property, creating silent self-binding loops.

---

## ⚖️ License & Copyright

© [Mayanktaker Computers & Web Development](https://mayanktaker.com) — Licensed under [MIT](LICENSE).
