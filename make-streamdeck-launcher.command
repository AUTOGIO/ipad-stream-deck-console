#!/bin/zsh
# Builds "Launch Codex Cheat Sheet.app" for Elgato Stream Deck (Open action).
# Also installs a copy under ~/Applications for easy browsing in Stream Deck.
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"
APP_NAME="Launch Codex Cheat Sheet.app"
APP_PATH="$SCRIPT_DIR/$APP_NAME"
HOME_APPS="$HOME/Applications"
HOME_APP_PATH="$HOME_APPS/$APP_NAME"
LAUNCHER="$SCRIPT_DIR/streamdeck-launch-cheatsheet.sh"

chmod +x "$LAUNCHER" "$SCRIPT_DIR/make-streamdeck-launcher.command" 2>/dev/null || true

rm -rf "$APP_PATH"

osacompile -o "$APP_PATH" <<EOF
on run
  do shell script "zsh " & quoted form of "$LAUNCHER"
end run
EOF

# Quiet icon-less app is fine; ad-hoc sign for local use.
codesign --force --deep --sign - "$APP_PATH" 2>/dev/null || true

mkdir -p "$HOME_APPS"
rm -rf "$HOME_APP_PATH"
ditto "$APP_PATH" "$HOME_APP_PATH"
codesign --force --deep --sign - "$HOME_APP_PATH" 2>/dev/null || true

echo "Created: $APP_PATH"
echo "Installed: $HOME_APP_PATH"
echo ""
echo "Stream Deck setup:"
echo "  1. Open Stream Deck software"
echo "  2. Drag System → Open onto a button"
echo "  3. Choose: $HOME_APP_PATH"
echo "  4. (Optional) Set a title like \"Cheat Sheet\""
