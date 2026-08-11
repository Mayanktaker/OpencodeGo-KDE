#!/usr/bin/env bash
# © Mayanktaker Computers & Web Development | https://mayanktaker.com
# Script to install opencode-usage CLI executable globally into ~/.local/bin/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.local/bin"
TARGET_PATH="$TARGET_DIR/opencode-usage"

# Ensure target bin directory exists
mkdir -p "$TARGET_DIR"

# Create symlink to CLI script
ln -sf "$SCRIPT_DIR/bin/opencode-usage" "$TARGET_PATH"
chmod +x "$TARGET_PATH"

echo "Successfully installed opencode-usage to $TARGET_PATH"
echo "You can now run 'opencode-usage' from any terminal window!"
