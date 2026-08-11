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

# Install CLI tool globally
"$SCRIPT_DIR/install-cli.sh"

echo "Setup Complete! Plasmoid installed to Plasma desktop and 'opencode-usage' CLI tool added to PATH."
