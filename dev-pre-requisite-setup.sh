#!/bin/bash
#
# This script installs all necessary system-wide dependencies.
# It is safe to re-run and will not reinstall existing software.
#

# Exit immediately if any command fails.
set -e

echo "🚀 Starting automated system dependency setup..."

# --- System Package Installation (dnf) ---
echo "📦 Checking and installing core system packages..."
PACKAGES=( "git" "make" "wget" "openssl-devel" "net-tools" "bind-utils" "bash-completion" "which" "procps" "gettext" "dnf-plugins-core" )
for pkg in "${PACKAGES[@]}"; do
    if ! rpm -q "$pkg" &> /dev/null; then
        echo "Installing package: $pkg..."
        sudo dnf install -y "$pkg"
    else
        echo "Package '$pkg' is already installed."
    fi
done
echo "✅ Core packages are up to date."

# --- Docker Installation & Configuration ---
if command -v docker &> /dev/null; then
    echo "✅ Docker is already installed."
else
    echo "🐳 Installing Docker Engine..."
    ##sudo dnf config-manager --addrepo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    echo "✅ Docker installed. Please log out and back in for permissions to apply."
fi

# --- Python 3.11 Installation ---
if command -v python3.11 &> /dev/null; then
    echo "✅ Python 3.11 is already installed."
else
    echo "🐍 Installing Python 3.11..."
    sudo dnf install -y python3.11 python3-pip
    sudo alternatives --install /usr/bin/python python3 /usr/bin/python3.11 1100
    sudo alternatives --set python3 /usr/bin/python3.11
    echo "✅ Python 3.11 installed."
fi

# --- Golang Installation ---
if [ -d "/usr/local/go" ]; then
    echo "✅ Go is already installed."
else
    echo "🐹 Installing Golang..."
    GO_VERSION="1.22.9"
    wget -qO- "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz" | sudo tar -C /usr/local -xzf -
    echo "✅ Golang installed."
fi

# --- OpenShift CLI (oc) Installation ---
if command -v oc &> /dev/null; then
    echo "✅ OpenShift CLI (oc) client is already installed."
else
    echo "☸️ Installing OpenShift CLI (oc) client..."
    # To ensure the latest stable version, we use the 'stable' directory
    # which is a symbolic link to the latest release.
    OC_URL="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz"
    
    echo "Downloading client from $OC_URL..."
    wget -qO /tmp/openshift-client-linux.tar.gz "$OC_URL"

    echo "Extracting 'oc' binary..."
    sudo tar -C /usr/local/bin -xzf /tmp/openshift-client-linux.tar.gz oc

    # Clean up the downloaded archive
    rm /tmp/openshift-client-linux.tar.gz

    echo "Ensuring 'oc' is executable..."
    sudo chmod +x /usr/local/bin/oc

    echo "✅ OpenShift CLI (oc) client installed."
fi

echo
echo "🎉 System setup complete!"
echo "----------------------------------------------------------------------"
echo "🔴  ACTION REQUIRED: Proceed to Part 2 to set up the Loopy project."
echo "----------------------------------------------------------------------"
