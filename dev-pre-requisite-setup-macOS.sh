#!/bin/bash
#
# This script installs all necessary system-wide dependencies for macOS.
# It is safe to re-run and will not reinstall existing software.
#
# Log file to capture all output
LOG_FILE="./dev-setup-$(date +"%Y-%m-%d_%H-%M-%S").log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "🚀 Starting automated system dependency setup for macOS..."
echo "Log file: $LOG_FILE"
echo "----------------------------------------------------------------------"

# --- Prompt for password at the start ---
echo "🔑 Please enter your password to grant administrative privileges."
sudo -v
if [ $? -ne 0 ]; then
    echo "❌ Failed to get sudo privileges. Exiting."
    exit 1
fi
echo "✅ Password accepted."

# --- Check and install Xcode Command Line Tools ---
echo "--- Checking for Xcode Command Line Tools..."
if xcode-select -p &> /dev/null; then
    echo "✅ Xcode Command Line Tools are already installed."
else
    echo "Installing Xcode Command Line Tools. A pop-up window may appear..."
    xcode-select --install
    until xcode-select -p &> /dev/null; do
        sleep 5
    done
    echo "✅ Xcode Command Line Tools installed."
fi

# --- Check and install Homebrew if not present ---
echo "--- Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "✅ Homebrew installed."
else
    echo "Homebrew is already installed. Updating Homebrew..."
    brew update
    echo "✅ Homebrew updated."
fi

# --- Core System Packages (via Homebrew) ---
echo "--- Checking and installing core system packages..."
HOMEBREW_FORMULAE=( "git" "make" "wget" "openssl@3" "gettext" "bash-completion" )
for pkg in "${HOMEBREW_FORMULAE[@]}"; do
    if ! brew list --formula | grep -q "^$(echo "$pkg" | cut -d'@' -f1)\$"; then
        echo "Installing Homebrew package: $pkg..."
        brew install "$pkg"
    else
        echo "✅ Homebrew package '$pkg' is already installed."
    fi
done

# --- Podman Installation & Configuration (via Homebrew Cask) ---
echo "--- Checking for Podman Desktop..."
if brew list --cask | grep -q "^podman-desktop\$"; then
    echo "✅ Podman Desktop is already installed."
else
    echo "Installing Podman Desktop..."
    brew install --cask podman-desktop
    echo "✅ Podman Desktop installed."
    echo ""
fi

# --- Python 3.11 Installation (via Homebrew) ---
echo "--- Checking for Python 3.11..."
if command -v python3.11 &> /dev/null; then
    echo "✅ Python 3.11 is already installed."
else
    echo "Installing Python 3.11..."
    brew install python@3.11
    if ! command -v python3 &> /dev/null || [[ "$(python3 --version 2>&1)" != *"Python 3.11"* ]]; then
        echo "Ensuring python3 symlink points to Homebrew's Python 3.11..."
        echo 'export PATH="/opt/homebrew/opt/python@3.11/bin:$PATH"' >> ~/.zshrc
        echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
        echo 'export PATH="/usr/local/opt/python@3.11/bin:$PATH"' >> ~/.bash_profile
        echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bash_profile
        echo "Please restart your terminal or run 'source ~/.zshrc' for Python 3.11 to be the default."
    fi
    echo "✅ Python 3.11 installed."
fi

# --- Visual Studio Code Installation (via Homebrew Cask) ---
echo "--- Checking for Visual Studio Code..."
if brew list --cask | grep -q "^visual-studio-code\$"; then
    echo "✅ Visual Studio Code is already installed."
else
    echo "Installing Visual Studio Code..."
    brew install --cask visual-studio-code
    echo "✅ Visual Studio Code installed."
fi

# --- Golang Installation (via Homebrew) ---
echo "--- Checking for Golang..."
if command -v go &> /dev/null; then
    echo "✅ Go is already installed."
else
    echo "Installing Golang..."
    brew install go
    echo "✅ Golang installed."
fi

echo ""
# --- Verification Check ---
echo "--- Final verification of installed tools..."
for cmd in git make wget openssl ifconfig dig nslookup which ps top gettext python3.11 pip3 code go; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "✅ $cmd is installed"
  else
    echo "❌ $cmd is NOT installed"
  fi
done
for cask in podman-desktop; do
  if brew list --cask | grep -q "^$cask\$"; then
    echo "✅ $cask is installed"
  else
    echo "❌ $cask is NOT installed"
  fi
done
echo ""
echo "Ensure all tools above have a green checkmark!"
echo ""
echo "🎉 System setup complete!"
echo "----------------------------------------------------------------------"
echo "🔴  ACTION REQUIRED:"
echo "    - You must launch **Podman Desktop** from your Applications folder and follow the in-app setup."
echo "      This will install the Podman engine and make the 'podman' command available in your terminal."
echo "    - To ensure your PATH is updated for Python and other tools, please restart your terminal or run 'source ~/.zshrc'."
echo "    - Proceed to Part 2 to set up the Loopy project."