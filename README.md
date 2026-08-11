<!-- © Mayanktaker Computers & Web Development | https://mayanktaker.com -->
# 📊 OpenCode Go Usage Tracker — KDE Plasma 6 Plasmoid & CLI

[![KDE Plasma](https://img.shields.io/badge/KDE-Plasma%206.5%2B-blue?logo=kde)](https://kde.org)
[![Qt](https://img.shields.io/badge/Qt-6.5%2B-green?logo=qt)](https://www.qt.io/)
[![Wayland](https://img.shields.io/badge/Display-Wayland%20%2F%20X11-orange)](https://wayland.freedesktop.org/)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)

A modern, highly customizable **KDE Plasma 6 (6.5.x+)** widget and companion command-line utility built for Linux (Fedora, Arch, Ubuntu, openSUSE) with native **Wayland** support. It tracks your **OpenCode Go** subscription usage across **Hourly**, **Weekly**, and **Monthly** intervals right from your desktop panel or taskbar.

---

## 🌟 Key Features

- 📊 **Multi-Interval Usage Tracking**: View real-time subscription consumption across 24-hour, 7-day, and 4-week periods with animated QML bar charts.
- 🎨 **4 Dark Theme Presets + Custom Color Pickers**:
  - **Catppuccin Mocha** *(Default)*
  - **Breeze Dark**
  - **Nord Dark**
  - **Dracula**
  - Full custom color picker support for Background, Text, Bar Primary, Bar Secondary, and Accent colors via Qt native `ColorDialog`.
- 🏷️ **Dynamic Panel Tray Badge**: Real-time percentage badge on the taskbar icon with automatic status color shifts:
  - `< 75%`: Configured theme accent color
  - `75% - 89%`: Warning Orange (`#ffb86c`)
  - `≥ 90%`: Critical Red (`#ff5555`)
- 🔔 **Desktop Quota Warning Notifications**: Native `KNotification` alerts when subscription quota usage crosses a user-configurable threshold (e.g. 80%).
- ⏱️ **Configurable Auto-Refresh**: Select refresh polling intervals of **30 seconds**, **1 minute**, **5 minutes**, or **10 minutes**.
- 💻 **Global Terminal CLI Utility (`opencode-usage`)**: Access usage stats directly from your shell with color-coded progress bars, raw JSON mode (`--json`), and tab completions for Bash and Zsh.
- 📁 **CSV Data Export**: Export complete usage statistics to CSV format with a single click.
- 🔒 **Cookie & Workspace Authentication**: Simple setup using session auth cookies extracted from `opencode.ai` with a built-in **Demo Mode** fallback.

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
2. Links the `opencode-usage` CLI tool to `~/.local/bin/opencode-usage`
3. Installs Bash autocompletions to `~/.local/share/bash-completion/completions/`

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
Test the widget in an isolated window without touching your panel layout:

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

# Output raw JSON payload (for scripts & polybar/i3 status bars)
opencode-usage --json

# Force Demo Mock Data mode
opencode-usage --demo

# Specify custom workspace ID and cookie on the fly
opencode-usage --workspace-id "ws_123" --cookie "auth_token_xyz"
```

---

## 🎨 Theme Presets

| Theme Preset | Background | Text | Bar Primary | Bar Secondary | Accent |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Catppuccin Mocha** | `#1e1e2e` | `#cdd6f4` | `#89b4fa` | `#74c7ec` | `#f38ba8` |
| **Breeze Dark** | `#232629` | `#eff0f1` | `#3daee9` | `#2980b9` | `#fd971f` |
| **Nord Dark** | `#2e3440` | `#eceff4` | `#88c0d0` | `#81a1c1` | `#bf616a` |
| **Dracula** | `#282a36` | `#f8f8f2` | `#bd93f9` | `#8be9fd` | `#ff5555` |

---

## 📁 Project Structure

```
OpencodeGo-KDE/
├── metadata.json                        # KDE Plasma 6 plugin manifest
├── contents/
│   ├── config/
│   │   ├── config.qml                   # Settings tab model (General, Appearance, About)
│   │   └── main.xml                     # kcfg XML configuration schema
│   ├── ui/
│   │   ├── main.qml                     # Root PlasmoidItem & timer manager
│   │   ├── CompactRepresentation.qml    # Taskbar icon & dynamic badge
│   │   ├── FullRepresentation.qml       # Expanded popup window & export action
│   │   ├── UsageBarChart.qml            # Pure QML animated bar chart
│   │   ├── UsageHeader.qml              # Subscription plan metadata header
│   │   ├── ViewSelector.qml            # Hourly / Weekly / Monthly view tabs
│   │   ├── configGeneral.qml            # Workspace & notification settings
│   │   ├── configAppearance.qml         # Preset & color pickers UI
│   │   └── configAbout.qml              # About tab & credits
│   └── code/
│       └── api.js                       # Data fetching, parsing & CSV generator
├── bin/
│   ├── opencode-usage                   # Executable CLI client
│   ├── opencode-usage-completion.bash   # Bash tab completion script
│   └── opencode-usage-completion.zsh    # Zsh tab completion script
├── install.sh                           # Master Plasmoid & CLI installer
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
