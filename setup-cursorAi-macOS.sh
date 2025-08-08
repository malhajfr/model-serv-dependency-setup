#!/usr/bin/env bash
#
# This script automates the installation of the Cursor AI Editor on macOS.
# It is safe to re-run and will not reinstall existing software.
#

echo "Installing Cursor AI Editor..."

# --- Step 1: Ensure Homebrew is installed ---
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "✅ Homebrew installed."
fi

# --- Step 2: Install Cursor via Homebrew Cask ---
echo "Downloading and installing Cursor..."
if brew list --cask | grep -q "^cursor\$"; then
    echo "✅ Cursor is already installed."
else
    brew install --cask cursor
    echo "✅ Cursor installed."
fi

# --- Step 3: Add alias to .zshrc ---
ALIAS_FILE="$HOME/.zshrc"
ALIAS_COMMAND="alias cursor='open -a Cursor'"

echo "Adding alias for easy command-line access..."
if ! grep -qxF "$ALIAS_COMMAND" "$ALIAS_FILE"; then
    echo "$ALIAS_COMMAND" >> "$ALIAS_FILE"
    echo "Added alias 'cursor' to $ALIAS_FILE"
else
    echo "✅ Alias 'cursor' already exists in $ALIAS_FILE."
fi

# --- Final message ---
echo
echo "✅ Installation complete."
echo "➡ Please restart your terminal or run 'source ~/.zshrc' for the alias to take effect."
echo "➡ Launch Cursor from your Applications folder or by running 'cursor' in a new terminal session."
