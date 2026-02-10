#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "=========================================="
echo "  Dotfiles Bootstrap Script"
echo "=========================================="
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo -e "${GREEN}Adding Homebrew to PATH for Apple Silicon...${NC}"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo -e "${GREEN}Homebrew is already installed.${NC}"
fi

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# Initialize and update git submodules
echo ""
echo -e "${YELLOW}Initializing Dotbot submodule...${NC}"
git submodule update --init --recursive

# Run Dotbot
echo ""
echo -e "${YELLOW}Running Dotbot configuration...${NC}"
"${DOTFILES_DIR}/dotbot/bin/dotbot" -d "${DOTFILES_DIR}" -c "${DOTFILES_DIR}/install.conf.yaml"

echo ""
echo -e "${GREEN}=========================================="
echo "  Bootstrap Complete!"
echo "==========================================${NC}"
echo ""
echo "Your development environment is now set up."
echo "Please check the post-installation instructions above."
echo ""
