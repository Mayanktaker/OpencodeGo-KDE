<!-- © Mayanktaker Computers & Web Development | https://mayanktaker.com -->
# OpenCode Go Usage Tracker — KDE Plasma 6 Widget

A modern, customizable KDE Plasma 6 widget (plasmoid) designed for KDE 6.5.x+ and Wayland support. It tracks your OpenCode Go subscription usage by hourly, weekly, and monthly intervals.

## Features

- 📊 **Usage Tracking**: View hourly, weekly, and monthly subscription usage with animated bar charts and tooltips.
- 🎨 **Theme Presets & Custom Colors**: Includes 4 dark theme presets:
  - **Catppuccin Mocha** (Default)
  - **Breeze Dark**
  - **Nord Dark**
  - **Dracula**
  - Custom color customization for Background, Text, Bar Primary, Bar Secondary, and Accent colors.
- 🔑 **Workspace & Cookie Auth**: Easily configure your Workspace ID and Auth Cookie directly from the settings dialog.
- ⏱️ **Configurable Refresh Rates**: Choose auto-refresh intervals of 30 seconds, 1 minute, 5 minutes, or 10 minutes.
- 🏷️ **Panel & Desktop Friendly**: Compact representation shows real-time percentage overlay on the panel icon.

## Installation

Run the automated installation script:

```bash
./install.sh
```

Or manually install using `kpackagetool6`:

```bash
kpackagetool6 -t Plasma/Applet -i .
```

To update an existing installation:

```bash
kpackagetool6 -t Plasma/Applet -u .
```

## How to get your Auth Cookie & Workspace ID

1. Open `https://opencode.ai` in your web browser and sign in.
2. Press `F12` to open Developer Tools.
3. Go to the **Application** (or **Storage**) tab -> **Cookies** -> `https://opencode.ai`.
4. Copy the value of the `auth` cookie.
5. In your OpenCode dashboard URL or network requests, locate your **Workspace ID**.
6. Right-click the widget -> **Configure OpenCode Go Usage Tracker...** -> Enter your credentials under **General**.

## Local Testing

You can test the widget in a standalone desktop window using `plasmawindowed`:

```bash
plasmawindowed com.mayanktaker.opencodego-usage
```

## License

MIT License © [Mayanktaker Computers & Web Development](https://mayanktaker.com)
