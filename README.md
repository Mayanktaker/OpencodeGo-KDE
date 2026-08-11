<!-- © Mayanktaker Computers & Web Development | https://mayanktaker.com -->
# 📊 OpenCode Go Usage Tracker — KDE Plasma 6 Plasmoid & CLI Utility

[![KDE Plasma](https://img.shields.io/badge/KDE-Plasma%206.5%2B-blue?logo=kde)](https://kde.org)
[![Qt](https://img.shields.io/badge/Qt-6.5%2B-green?logo=qt)](https://www.qt.io/)
[![Wayland](https://img.shields.io/badge/Display-Wayland%20%2F%20X11-orange)](https://wayland.freedesktop.org/)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)

A modern, feature-rich **KDE Plasma 6 (6.5.x+)** widget and companion command-line utility built for Linux (Fedora, Arch, Ubuntu, openSUSE) with native **Wayland** support. It tracks your **OpenCode Go** subscription usage across **Hourly**, **Weekly**, and **Monthly** intervals right from your desktop panel or taskbar.

---

## 🌟 Key Features

- 📊 **Multi-Interval Usage Tracking**: View real-time subscription consumption across 24-hour, 7-day, and 4-week periods with animated QML bar charts and smart 24-hour X-axis step filtering.
- 📐 **3 Display Layout Modes**:
  - **Tabbed View**: Switch between Hourly, Weekly, and Monthly charts using tab controls.
  - **All-in-One Dashboard**: Display all 3 interval charts simultaneously in a single scrollable dashboard view.
  - **Horizontal Progress Bars**: Compact progress rows with animated fill width transitions and percentage badges.
- ⚡ **1-Click Header Layout Switcher**: Instantly toggle between Tabbed, Horizontal Progress Bars, and All-in-One Dashboard layouts directly from the widget header with 1 click.
- ⚡ **Quota Burn-Rate Velocity Estimator**: Automatically calculates your daily request consumption velocity and displays remaining days left (`Est. ~14 days left`).
- 🎨 **12 Developer Theme Presets (8 Dark + 4 White/Light)**:
  - **Dark Themes**: Catppuccin Mocha *(Default)*, Breeze Dark, Nord Dark, Dracula, Solarized Dark, Gruvbox Dark, Tokyo Night, One Dark (VS Code).
  - **Light/White Themes**: Breeze Light (White), Catppuccin Latte (White), Solarized Light (White), Paper White.
  - Full custom color picker support for Background, Text, Bar Primary, Bar Secondary, and Accent colors via Qt native `ColorDialog`.
- 🔲 **Outer Border & Header Toggle Options**: Show/hide widget header title and enable/disable outer card border outline.
- 🏷️ **Dynamic Panel Tray Badge**: Real-time percentage badge on the taskbar icon with automatic status color shifts:
  - `< 75%`: Configured theme accent color
  - `75% - 89%`: Warning Orange (`#ffb86c`)
  - `≥ 90%`: Critical Red (`#ff5555`)
- 🔔 **Native KDE Desktop Quota Alerts**: System warning notification toasts trigger when subscription quota usage crosses your configured alert threshold (e.g. 80%).
- 💻 **Global Terminal CLI Utility (`opencode-usage`)**: Access usage stats directly from your shell with color-coded progress bars, raw JSON mode (`--json`), CSV file export (`--export`), and tab completions for Bash and Zsh.
- 📁 **CSV Data Export**: Export complete usage statistics to formatted CSV format from the widget or terminal.
- 🖼️ **Multi-Resolution System Icon Theme Integration**: Vector SVG + 6 PNG sizes (`128x128`, `64x64`, `48x48`, `32x32`, `22x22`, `16x16`) with `index.theme` for instant KDE Widget Explorer indexing.
- 👨‍💻 **Developer Credits & PayPal Support Card**: Dedicated developer details, website link (`mayanktaker.com`), and PayPal donation integration (`mayanktaker_hell@yahoo.co.in`).

---

## 🖥️ System Requirements

| Component | Minimum Requirement | Recommended |
| :--- | :--- | :--- |
| **Operating System** | Fedora 39+, Arch Linux, Ubuntu 24.04+, openSUSE Tumbleweed | Any modern Linux distro with KDE |
| **Desktop Environment** | KDE Plasma 6.0+ | KDE Plasma 6.5.x+ |
| **Qt Version** | Qt 6.5+ | Qt 6.7+ |
| **Display Server** | Wayland or X11 | Wayland |
| **Dependencies** | `kpackagetool6`, `plasma-workspace-devel`, `python3` | Pre-installed on KDE Plasma 6 |

---

## 🚀 Installation Guide

### Quick 1-Step Installation (Plasmoid + CLI)

Clone the repository and run the master installer script:

```bash
git clone https://github.com/mayanktaker/OpencodeGo-KDE.git
cd OpencodeGo-KDE
./install.sh
```

This single command automatically:
1. Validates and installs/upgrades the Plasmoid to `~/.local/share/plasma/plasmoids/com.mayanktaker.opencodego-usage/`
2. Registers custom MT branding vector SVG and multi-resolution PNG icons in `~/.local/share/icons/hicolor/`
3. Purges all Plasma QML bytecode caches and restarts `plasmashell` live
4. Links the `opencode-usage` CLI tool to `~/.local/bin/opencode-usage`
5. Installs Bash autocompletions to `~/.local/share/bash-completion/completions/`

### Fedora Package Prerequisites (If `kpackagetool6` is missing)

If `kpackagetool6` is not found on your Fedora system, install the KDE development package:

```bash
sudo dnf install plasma-workspace-devel
```

---

## 🔑 How to Get Your Workspace ID & Auth Cookie

1. Open `https://opencode.ai` in Google Chrome, Firefox, or Brave and sign in.
2. Press `F12` to open Developer Tools.
3. Navigate to **Application** *(or Storage)* → **Cookies** → `https://opencode.ai`.
4. Copy the value of the `auth` cookie.
5. Right-click the widget on your KDE panel → **Configure OpenCode Go Usage Tracker...**
6. Under the **General** tab, paste your **Workspace ID** and **Auth Cookie**.
7. Click **Apply** or **OK**.

---

## 🧪 Testing the Widget

### Standalone Window Mode (Quick Testing)

Test the widget in an isolated test window without touching your panel layout:

```bash
plasmawindowed com.mayanktaker.opencodego-usage
```

### Adding to Desktop / Panel

1. Right-click your KDE Plasma panel or desktop → **Add Widgets...**
2. Search for **OpenCode Go Usage Tracker**.
3. Drag and drop the widget onto your panel or desktop.

---

## 💻 Terminal CLI Utility (`opencode-usage`)

The widget includes a standalone Python CLI client that reads your KDE widget configuration automatically.

### Commands & Options

```bash
# Display formatted terminal UI with progress bars
opencode-usage

# Export usage statistics to CSV file
opencode-usage --export /tmp/usage.csv

# Output raw JSON payload (for scripts & polybar/i3 status bars)
opencode-usage --json

# Force Demo Mock Data mode
opencode-usage --demo

# Specify custom workspace ID and cookie on the fly
opencode-usage --workspace-id "ws_123" --cookie "auth_token_xyz"
```

---

## 🎨 Theme Presets List

| Theme Preset | Type | Background | Text | Bar Primary | Bar Secondary | Accent |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Catppuccin Mocha** | Dark | `#1e1e2e` | `#cdd6f4` | `#89b4fa` | `#74c7ec` | `#f38ba8` |
| **Breeze Dark** | Dark | `#232629` | `#eff0f1` | `#3daee9` | `#2980b9` | `#fd971f` |
| **Nord Dark** | Dark | `#2e3440` | `#eceff4` | `#88c0d0` | `#81a1c1` | `#bf616a` |
| **Dracula** | Dark | `#282a36` | `#f8f8f2` | `#bd93f9` | `#8be9fd` | `#ff5555` |
| **Solarized Dark** | Dark | `#002b36` | `#839496` | `#268bd2` | `#2aa198` | `#b58900` |
| **Gruvbox Dark** | Dark | `#282828` | `#ebdbb2` | `#83a598` | `#8ec07c` | `#fabd2f` |
| **Tokyo Night** | Dark | `#1a1b26` | `#c0caf5` | `#7aa2f7` | `#7dcfff` | `#f7768e` |
| **One Dark (VS Code)** | Dark | `#282c34` | `#abb2bf` | `#61afef` | `#56b6c2` | `#e06c75` |
| **Breeze Light (White)** | Light | `#ffffff` | `#232629` | `#3daee9` | `#2980b9` | `#da4453` |
| **Catppuccin Latte (White)** | Light | `#eff1f5` | `#4c4f69` | `#1e66f5` | `#209fb5` | `#8839ef` |
| **Solarized Light (White)** | Light | `#fdf6e3` | `#657b83` | `#268bd2` | `#2aa198` | `#b58900` |
| **Paper White** | Light | `#f8f9fa` | `#212529` | `#0d6efd` | `#0dcaf0` | `#d63384` |

---

## 📁 Project Structure

```
OpencodeGo-KDE/
├── metadata.json                        # KDE Plasma 6 plugin manifest
├── contents/
│   ├── config/
│   │   ├── config.qml                   # Settings tab model (General, Appearance, Credits & Support)
│   │   └── main.xml                     # kcfg XML configuration schema
│   ├── ui/
│   │   ├── main.qml                     # Root PlasmoidItem & timer manager
│   │   ├── CompactRepresentation.qml    # Taskbar icon & dynamic badge
│   │   ├── FullRepresentation.qml       # Expanded popup window & export action
│   │   ├── UsageBarChart.qml            # Pure QML animated bar chart
│   │   ├── HorizontalUsageBars.qml      # Compact horizontal progress rows layout
│   │   ├── UsageHeader.qml              # Subscription plan metadata & 1-click layout toggle
│   │   ├── ViewSelector.qml            # Hourly / Weekly / Monthly view tabs
│   │   ├── configGeneral.qml            # Workspace & notification settings
│   │   ├── configAppearance.qml         # Preset & color pickers UI
│   │   └── configAbout.qml              # Developer credits & PayPal support cards
│   └── code/
│       └── api.js                       # Data fetching, parsing & CSV generator
├── bin/
│   ├── opencode-usage                   # Executable CLI client (--json, --export)
│   ├── opencode-usage-completion.bash   # Bash tab completion script
│   └── opencode-usage-completion.zsh    # Zsh tab completion script
├── assets/
│   ├── icon.svg                         # Vector branding icon
│   └── branding-icon.jpg                # High-res branding artwork
├── install.sh                           # Master Plasmoid, Icon & CLI installer
├── install-cli.sh                       # Global CLI installer
├── .gitignore                           # Git ignore rules
├── LICENSE                              # MIT License
└── README.md                            # Documentation
```

---

## ⚖️ License & Copyright

Designed and developed by **Mayanktaker Computers & Web Development**.

Licensed under the **MIT License**. See [LICENSE](LICENSE) for details.

© [Mayanktaker Computers & Web Development](https://mayanktaker.com)
