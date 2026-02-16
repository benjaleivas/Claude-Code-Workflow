#!/bin/bash
# One-time setup for Claude Container infrastructure.
# Installs Colima, Docker, and Just. Builds the container image.
set -e

CONTAINER_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Claude Container Setup ==="
echo ""

# Check for Homebrew
if ! command -v brew &>/dev/null; then
    echo "Error: Homebrew not found. Install from https://brew.sh"
    exit 1
fi

# Install dependencies
echo "Installing Colima, Docker, and Just..."
brew install colima docker just 2>/dev/null || true

# Start Colima (Apple Silicon, 4 CPU, 8GB RAM)
echo ""
echo "Starting Colima VM..."
colima start --arch aarch64 --cpu 4 --memory 8 --disk 60

# Build the image
echo ""
echo "Building container image..."
cd "$CONTAINER_DIR"
docker build -t claude-workspace .

# Create projects directory
mkdir -p "$CONTAINER_DIR/projects"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Quick start:"
echo "  cd $CONTAINER_DIR"
echo "  just create my-project    # create a container"
echo "  just yolo my-project      # start Claude in YOLO mode"
echo "  just shell my-project     # get a shell"
echo "  just destroy my-project   # remove container (files persist)"
echo ""
echo "Run 'just --list' for all available commands."
