#!/usr/bin/env bash
#
# setup-devenv.sh - Setup development environment with distrobox
#
# Usage: ./setup-devenv.sh [ubuntu|fedora|debian] [container-name]
#

set -euo pipefail

DISTRO="${1:-ubuntu}"
CONTAINER_NAME="${2:-${DISTRO}-dev}"

echo "💻 Setting up development environment"
echo ""
echo "Distribution: $DISTRO"
echo "Container name: $CONTAINER_NAME"
echo ""

# Check if distrobox available
if ! command -v distrobox &> /dev/null; then
    echo "❌ distrobox not found!"
    echo ""
    echo "On Bazzite, install with:"
    echo "  rpm-ostree install distrobox"
    echo "  systemctl reboot"
    echo ""
    echo "Or use toolbox (pre-installed):"
    echo "  toolbox create $CONTAINER_NAME"
    exit 1
fi

# Select image
case "$DISTRO" in
    ubuntu)
        IMAGE="docker.io/library/ubuntu:24.04"
        ;;
    fedora)
        IMAGE="registry.fedoraproject.org/fedora:41"
        ;;
    debian)
        IMAGE="docker.io/library/debian:stable"
        ;;
    *)
        echo "❌ Unknown distribution: $DISTRO"
        echo "   Supported: ubuntu, fedora, debian"
        exit 1
        ;;
esac

# Create container
echo "📦 Creating distrobox container..."
echo "   Image: $IMAGE"
echo "   Name: $CONTAINER_NAME"
echo ""

distrobox create \
    --name "$CONTAINER_NAME" \
    --image "$IMAGE" \
    --home "$HOME/distrobox/$CONTAINER_NAME" \
    --additional-packages "git curl wget build-essential" \
    --init \
    --yes

echo ""
echo "✅ Container created: $CONTAINER_NAME"
echo ""

# Enter container and setup
echo "🔧 Setting up container environment..."
echo ""

distrobox enter "$CONTAINER_NAME" -- bash -c '
set -euo pipefail

echo "📦 Updating package manager..."
if command -v apt &> /dev/null; then
    sudo apt update
    sudo apt install -y \
        git curl wget \
        build-essential \
        python3 python3-pip python3-venv \
        nodejs npm \
        vim nano
elif command -v dnf &> /dev/null; then
    sudo dnf update -y
    sudo dnf install -y \
        git curl wget \
        @development-tools \
        python3 python3-pip \
        nodejs npm \
        vim nano \
        podman buildah
fi

echo ""
echo "📥 Installing KENL1 framework..."
if [ -d "$HOME/kenl/KENL1-framework/atom-sage-framework" ]; then
    cd "$HOME/kenl/KENL1-framework/atom-sage-framework"
    ./install.sh
    echo "✅ KENL1 framework installed"
else
    echo "⚠️  KENL1 framework not found at ~/kenl/KENL1-framework"
    echo "   Container can still be used, but ATOM trail unavailable"
fi

echo ""
echo "✅ Container setup complete!"
'

echo ""
echo "✅ Development environment ready!"
echo ""
echo "Usage:"
echo "  Enter container:"
echo "    distrobox enter $CONTAINER_NAME"
echo ""
echo "  Run command in container:"
echo "    distrobox enter $CONTAINER_NAME -- python3 --version"
echo ""
echo "  Export application to host:"
echo "    distrobox enter $CONTAINER_NAME"
echo "    distrobox-export --app code"
echo ""
echo "  Remove container:"
echo "    distrobox rm $CONTAINER_NAME"

# Log with ATOM if available
if command -v atom &> /dev/null; then
    atom CONFIG "Created dev environment: $CONTAINER_NAME" "Distro: $DISTRO, Image: $IMAGE"
fi
