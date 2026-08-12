#!/usr/bin/env bash
# © Mayanktaker Computers & Web Development | https://mayanktaker.com
# Installation and upgrade script for OpenCode Go KDE Plasmoid & CLI Utility

set -e

PLASMOID_ID="com.mayanktaker.opencodego-usage"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing OpenCode Go Usage Plasmoid ($PLASMOID_ID)..."

# Check if kpackagetool6 is available
if ! command -v kpackagetool6 &> /dev/null; then
    echo "Error: kpackagetool6 not found. Make sure KDE Plasma 6 development tools are installed."
    exit 1
fi

# Try upgrading first, if fails try installing
if kpackagetool6 -t Plasma/Applet --list | grep -q "$PLASMOID_ID"; then
    echo "Upgrading existing plasmoid..."
    kpackagetool6 -t Plasma/Applet -u "$SCRIPT_DIR"
else
    echo "Installing new plasmoid..."
    kpackagetool6 -t Plasma/Applet -i "$SCRIPT_DIR"
fi

# Ensure hicolor icon theme structure and index.theme exist in user icons directory
echo "Installing custom MT branding icons to hicolor icon theme..."
ICON_BASE="$HOME/.local/share/icons/hicolor"
mkdir -p "$ICON_BASE/scalable/apps/"
mkdir -p "$ICON_BASE/128x128/apps/"
mkdir -p "$ICON_BASE/64x64/apps/"
mkdir -p "$ICON_BASE/48x48/apps/"
mkdir -p "$ICON_BASE/32x32/apps/"
mkdir -p "$ICON_BASE/22x22/apps/"
mkdir -p "$ICON_BASE/16x16/apps/"

# Create index.theme if missing so Qt QIcon::fromTheme scans user hicolor folder
if [ ! -f "$ICON_BASE/index.theme" ]; then
cat << 'EOF' > "$ICON_BASE/index.theme"
[Icon Theme]
Name=Hicolor
Comment=Fallback icon theme
Hidden=true
Directories=scalable/apps,128x128/apps,64x64/apps,48x48/apps,32x32/apps,22x22/apps,16x16/apps

[scalable/apps]
Size=48
Scale=1
MinSize=1
MaxSize=512
Context=Applications
Type=Scalable

[128x128/apps]
Size=128
Context=Applications
Type=Fixed

[64x64/apps]
Size=64
Context=Applications
Type=Fixed

[48x48/apps]
Size=48
Context=Applications
Type=Fixed

[32x32/apps]
Size=32
Context=Applications
Type=Fixed

[22x22/apps]
Size=22
Context=Applications
Type=Fixed

[16x16/apps]
Size=16
Context=Applications
Type=Fixed
EOF
fi

# Copy scalable SVG icon
if [ -f "$SCRIPT_DIR/assets/icon.svg" ]; then
    cp "$SCRIPT_DIR/assets/icon.svg" "$ICON_BASE/scalable/apps/$PLASMOID_ID.svg"
    mkdir -p "$SCRIPT_DIR/contents/icons/"
    cp "$SCRIPT_DIR/assets/icon.svg" "$SCRIPT_DIR/contents/icons/$PLASMOID_ID.svg"
fi

# Generate PNG icon representations across all standard icon sizes from redesigned SVG logo
CONVERT_CMD=""
if command -v magick &> /dev/null; then
    CONVERT_CMD="magick"
elif command -v convert &> /dev/null; then
    CONVERT_CMD="convert"
fi

if [ -n "$CONVERT_CMD" ] && [ -f "$SCRIPT_DIR/assets/icon.svg" ]; then
    echo "Generating PNG app icon sizes from redesigned SVG logo..."
    for s in 128 64 48 32 22 16; do
        out_dir="$ICON_BASE/${s}x${s}/apps"
        mkdir -p "$out_dir"
        $CONVERT_CMD -background none "$SCRIPT_DIR/assets/icon.svg" -resize "${s}x${s}" "$out_dir/$PLASMOID_ID.png" 2>/dev/null || true
    done
fi

# Rebuild GTK icon cache & KDE Sycoca service index
gtk-update-icon-cache -f "$ICON_BASE" 2>/dev/null || true
kbuildsycoca6 --noincremental 2>/dev/null || true

# Purge ALL Plasma QML bytecode cache locations so plasmashell and settings read fresh files
echo "Clearing all Plasma QML bytecode caches..."
rm -rf "$HOME/.cache/plasmashell/" "$HOME/.cache/plasmawindowed/" "$HOME/.cache/qmlcache/" "$HOME/.cache/kcmshell6/" "$HOME/.cache/systemsettings/" "$HOME/.cache/kwin/" 2>/dev/null || true

# Restart live plasmashell process so desktop widgets reload fresh code immediately
echo "Restarting live Plasma Shell..."
systemctl --user restart plasma-plasmashell.service 2>/dev/null || (kquitapp6 plasmashell 2>/dev/null && kstart plasmashell 2>/dev/null &) || true

# Install CLI tool globally
"$SCRIPT_DIR/install-cli.sh"

echo "Setup Complete! Plasmoid updated, custom MT icon installed across all sizes to system theme, all QML caches cleared, Plasma Shell restarted, and 'opencode-usage' CLI tool added to PATH."
