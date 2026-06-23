#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.config/quickshell-stickynotes"
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

echo "Installing quickshell-stickynotes..."

if [ -d "$INSTALL_DIR" ]; then
    echo "Existing install found at $INSTALL_DIR — backing up to ${INSTALL_DIR}.bak"
    mv "$INSTALL_DIR" "${INSTALL_DIR}.bak"
fi

cp -r "$REPO_DIR/qml" "$INSTALL_DIR"
cp "$REPO_DIR/hyprland-windowrules.conf" "$INSTALL_DIR/hyprland-windowrules.conf"
mkdir -p "$HOME/.local/share/quickshell-stickynotes"

EXEC_LINE="exec-once = qs -c $INSTALL_DIR"

if [ -f "$HYPR_CONF" ]; then
    if grep -qF "$EXEC_LINE" "$HYPR_CONF"; then
        echo "exec-once line already present in hyprland.conf, skipping."
    else
        echo "" >> "$HYPR_CONF"
        echo "# quickshell-stickynotes autostart" >> "$HYPR_CONF"
        echo "$EXEC_LINE" >> "$HYPR_CONF"
        echo "Added autostart line to $HYPR_CONF"
    fi
else
    echo "Couldn't find hyprland.conf at $HYPR_CONF"
    echo "Add this line manually to your compositor config:"
    echo "  $EXEC_LINE"
fi

echo "Done. Reload Hyprland or run manually to test:"
echo "  qs -c $INSTALL_DIR"
echo ""
echo "Optional: to keep the Notes Manager window floating instead of tiled,"
echo "add this line to your hyprland.conf yourself (not done automatically):"
echo "  source = $INSTALL_DIR/hyprland-windowrules.conf"
