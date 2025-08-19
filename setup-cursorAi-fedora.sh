#!/usr/bin/env bash
set -e

APPIMAGE_URL="https://downloader.cursor.sh/linux/appImage/x64"
APPIMAGE_PATH="/opt/cursor.appimage"
ICON_URL="https://raw.githubusercontent.com/rahuljangirwork/copmany-logos/refs/heads/main/cursor.png"
ICON_PATH="/opt/cursor.png"
DESKTOP_FILE="/usr/share/applications/cursor.desktop"
ALIAS_FILE="$HOME/.bashrc"

echo "Installing Cursor AI Editor..."

# Step 1: Ensure curl is installed
if ! command -v curl >/dev/null 2>&1; then
  echo "Installing curl..."
  sudo apt-get update
  sudo apt-get install -y curl
fi

# Step 2: Download Cursor AppImage
echo "Downloading Cursor AppImage..."
sudo curl -L "$APPIMAGE_URL" -o "$APPIMAGE_PATH"
sudo chmod +x "$APPIMAGE_PATH"

# Step 3: Download Cursor icon
echo "Downloading icon..."
sudo curl -L "$ICON_URL" -o "$ICON_PATH"

# Step 4: Create .desktop file
echo "Creating desktop entry..."
sudo bash -c "cat > $DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Cursor AI IDE
Exec=$APPIMAGE_PATH --no-sandbox
Icon=$ICON_PATH
Type=Application
Categories=Development;
EOF

# Step 5: Add alias to .bashrc
if ! grep -qxF "alias cursor=" "$ALIAS_FILE"; then
  echo "alias cursor='$APPIMAGE_PATH --no-sandbox'" >> "$ALIAS_FILE"
  echo "Added alias 'cursor' to $ALIAS_FILE"
fi

# Step 6: Try launching to detect libfuse error
echo
echo "Testing launch to detect potential libfuse errors..."
set +e
OUTPUT=$($APPIMAGE_PATH --no-sandbox 2>&1)
EXIT_CODE=$?
set -e

if echo "$OUTPUT" | grep -q "dlopen(): error loading libfuse.so.2"; then
  echo "⚠ Detected missing libfuse.so.2 library."
  echo "Installing libfuse2 to fix this..."
  sudo apt-get install -y libfuse2

  echo "Retrying launch..."
  $APPIMAGE_PATH --no-sandbox &
else
  echo "✅ No libfuse error detected. Cursor is ready to use."
fi

# Final message
echo
echo "✅ Installation complete."
echo "➡ Launch Cursor from Applications menu or by running: cursor"
